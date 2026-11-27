import json
import logging

from django.db import transaction
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from botocore.exceptions import ClientError

from accounts.models import User
from community.models import Community
from timeline.models import Post, PostMedia

from core.firebase import verify_id_token
from core.storage import s3_client, bucket_name


logger = logging.getLogger(__name__)

# 投稿の制限値
MAX_IMAGES = 4
MAX_IMAGES_BYTES = 10 * 1024 * 1024
MAX_VIDEO_BYTES = 200 * 1024 * 1024


def _check_keys(user, keys, max_bytes):
    """S3上にアップロード済みのメディアキーが妥当か検証する"""
    print(f"[postCreateView._check_keys] 開始: user_id={user.pk}, keys={keys}, max_bytes={max_bytes}")

    s3 = s3_client()
    # ユーザーごとの許可プレフィックス（他人のキーを指定されるのを防ぐ）
    prefix = f"posts/{user.pk}/"
    target_bucket = bucket_name("posts")
    print(f"[postCreateView._check_keys] bucket={target_bucket}, prefix={prefix}")

    for idx, key in enumerate(keys, start=1):
        print(f"[postCreateView._check_keys] ({idx}/{len(keys)}) key検証中: {key}")

        # 文字列かつ自ユーザーのプレフィックスで始まっているか確認
        if not isinstance(key, str) or not key.startswith(prefix):
            print(f"[postCreateView._check_keys] NG: invalid_key -> {key}")
            return "invalid_key"

        try:
            # S3オブジェクトの存在とメタデータ（サイズ等）を取得
            head = s3.head_object(
                Bucket=target_bucket,
                Key=key
            )
        except ClientError as e:
            print(f"[postCreateView._check_keys] NG: file_not_uploaded (S3未存在) -> {key}, err={e}")
            return "file_not_uploaded"

        size = head.get("ContentLength", 0)
        print(f"[postCreateView._check_keys] S3存在確認OK: key={key}, size={size} bytes")

        # ファイルサイズ上限チェック
        if size > max_bytes:
            print(f"[postCreateView._check_keys] NG: file_too_large -> size={size} > max={max_bytes}")
            return "file_too_large"

    print("[postCreateView._check_keys] 全キー検証OK")
    return None


@csrf_exempt
@require_POST
def postCreateView(request):
    """新規投稿（および返信・メディア付き投稿）を作成するAPI"""
    print("[postCreateView] === 投稿作成処理 開始 ===")

    # 1. AuthorizationヘッダーからBearerトークンを取得
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        print("[postCreateView] NG: AuthorizationヘッダーにBearerトークンがありません")
        return JsonResponse({"error": "no_token"}, status=401)

    token = header[7:]
    print("[postCreateView] Bearerトークン取得完了 -> Firebaseトークン検証へ")

    # 2. Firebase IDトークンの検証とUID取得
    try:
        uid = verify_id_token(token)["uid"]
        print(f"[postCreateView] Firebaseトークン検証OK: uid={uid}")
    except Exception as e:
        logger.exception("verify_id_token_failed")
        print(f"[postCreateView] NG: Firebaseトークン検証失敗 -> {e}")
        return JsonResponse({"error": "invalid_token"}, status=401)

    # 3. UIDに対応するアプリ内ユーザーを検索
    user = User.objects.filter(firebase_uid=uid).first()
    if user is None:
        print(f"[postCreateView] NG: 該当ユーザーがDBに見つかりません (uid={uid})")
        return JsonResponse({"error": "user_not_found"}, status=404)

    print(f"[postCreateView] ユーザー特定OK: user_id={user.pk}")

    # 4. リクエストボディ（JSON）のパース
    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError as e:
        print(f"[postCreateView] NG: JSONパースエラー -> {e}")
        return JsonResponse({"error": "invalid_json"}, status=400)

    # 5. 入力パラメータの取り出しと整形
    community_id = body.get("community_id")
    text = (body.get("post") or "").strip()
    reply_id = body.get("reply_id")
    keys = body.get("keys") or []
    media_type = body.get("media_type")
    print(
        f"[postCreateView] パラメータ受信: community_id={community_id}, "
        f"text_len={len(text)}, reply_id={reply_id}, keys_count={len(keys)}, media_type={media_type}"
    )

    # 6. 必須項目のバリデーション
    if not community_id:
        print("[postCreateView] NG: community_idが未指定です")
        return JsonResponse({"error": "community_required"}, status=400)

    # if not text:
    #     print("[postCreateView] NG: 投稿本文が空です")
    #     return JsonResponse({"error": "empty_post"}, status=400)

    # 7. 投稿先コミュニティの存在確認
    try:
        community = Community.objects.get(id=community_id)
        print(f"[postCreateView] コミュニティ確認OK: community_id={community.id}")
    except Community.DoesNotExist:
        print(f"[postCreateView] NG: コミュニティが存在しません (community_id={community_id})")
        return JsonResponse({"error": "community_not_found"}, status=404)

    # 8. メディア種別のバリデーション
    if media_type not in (
        PostMedia.IMAGE,
        PostMedia.VIDEO,
        None,
    ):
        print(f"[postCreateView] NG: 不正なmedia_type -> {media_type}")
        return JsonResponse(
            {"error": "invalid_media_type"},
            status=400
        )

    # 9. 返信先投稿（reply_id指定時）の存在確認
    reply_post = None
    if reply_id:
        try:
            reply_post = Post.objects.get(id=reply_id)
            print(f"[postCreateView] 返信先投稿確認OK: reply_post_id={reply_post.id}")
        except Post.DoesNotExist:
            print(f"[postCreateView] NG: 返信先投稿が存在しません (reply_id={reply_id})")
            return JsonResponse({"error": "reply_not_found"}, status=404)

    # 10. 添付メディアキーの件数・S3存在・サイズ検証
    # ※現状は MAX_VIDEO_BYTES でチェックしているため、画像のみの場合に上限を変えたい場合は分岐を調整してください
    if keys:
        print(f"[postCreateView] メディアキー検証開始: 件数={len(keys)}")
        if len(keys) > MAX_IMAGES:
            print(f"[postCreateView] NG: ファイル数上限超過 -> {len(keys)} > {MAX_IMAGES}")
            return JsonResponse({"error": "too_many_files"}, status=400)

        err = _check_keys(
            user,
            keys,
            MAX_VIDEO_BYTES
        )

        if err:
            print(f"[postCreateView] NG: _check_keysエラー -> {err}")
            return JsonResponse({"error": err}, status=400)

    # 11. DB登録処理（投稿本体・メディア紐付け・返信数インクリメントをトランザクションで一括実行）
    print("[postCreateView] DBトランザクション開始")
    with transaction.atomic():
        post = Post.objects.create(
            user=user,
            community=community,
            post=text,
            reply=reply_post,
        )
        print(f"[postCreateView] Post作成完了: post_id={post.id}")

        for n, key in enumerate(keys, start=1):
            media_obj = PostMedia.objects.create(
                post=post,
                media=key,
                mediaType=media_type,
                mediaNumber=n,
            )
            print(
                f"[postCreateView] PostMedia作成完了: id={media_obj.id}, "
                f"mediaNumber={n}, mediaType={media_type}, key={key}"
            )

        if reply_post:
            reply_post.replyCount += 1
            reply_post.save(update_fields=["replyCount"])
            print(f"[postCreateView] 返信先replyCount更新完了: reply_post_id={reply_post.id}, new_count={reply_post.replyCount}")

    print(f"[postCreateView] === 投稿作成処理 完了: post_id={post.id} ===")
    return JsonResponse(
        {"id": post.id},
        status=201
    )