import json
import logging
from django.conf import settings
from django.db import transaction
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from botocore.exceptions import ClientError
from accounts.models import User
from core.firebase import verify_id_token
from core.storage import s3_client,bucket_name
from work.models import Work, Work_char, Work_image, Work_movie

# S3に登録できた作品、また文字作品をDBに登録する関数
# 投稿者・ファイルの場所・サイズなど、サーバー側で確認できるものは確認する。

# 認証エラー処理用変数
logger = logging.getLogger(__name__)

# グローバル変数を定義
MAX_IMAGES = 20
MAX_IMAGES_BYTES = 10 * 1024 * 1024
MAX_VIDEO_BYTES = 200 * 1024 * 1024


# アップロード済みのファイルの確認をするための関数
def _check_keys(user, keys, max_bytes):
    # s3を扱うメソッドを変数に定義
    s3 = s3_client()
    # 自分のworkを入れるurl
    prefix = f"works/{user.pk}/"

    # keyの回数分回す
    for key in keys:
        # 文字列で尚且つ自分のフォルダかを確認し、違かったらreturn
        if not isinstance(key, str) or not key.startswith(prefix):
            return "invalid_key"

    
        try:
            head = s3.head_object(
                Bucket=bucket_name("works"),
                Key=key
            )
        except ClientError:
            return "file_not_uploaded"

        if head["ContentLength"] > max_bytes:
            return "file_too_large"

    return None


@csrf_exempt      #アプリ（flutter）からのPOSTを受けるため、CSRFチェックを外す
@require_POST     #POST以外（GETなど）で来たら、405エラーで断る
def workCreateView(request):
    header = request.headers.get("Authorization", "")

    if not header.startswith("Bearer "):
        return JsonResponse({"error": "no_token"}, status=401)

    try:
        uid = verify_id_token(header[7:])["uid"]

    except Exception:
        logger.exception("verify_id_token feilled")
        return JsonResponse({"error": "invalid_token"}, status=401)

    # トークンのuid(firebase_uid)から、DBのユーザーを探す
    user = User.objects.filter(firebase_uid=uid).first()

    if user is None:
        return JsonResponse({"error": "user_not_found"}, status=404)

    try:
        body = json.loads(request.body or "{}")

    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)

    title = (body.get("title") or "").strip()
    work_type = body.get("work_type")
    work_detail = body.get("work_detail") or ""

    if not title or len(title) > 50:
        return JsonResponse({"error": "invalid_title"}, status=400)

    if work_type not in (1, 2, 3):
        return JsonResponse({"error": "invalid_work_type"}, status=400)

    keys = body.get("keys") or []
    text = body.get("text") or ""

    if work_type == 1:
        if not text.strip():
            return JsonResponse({"error": "empty_text"}, status=400)

    else:
        if work_type == 2:
            max_count, max_bytes = MAX_IMAGES, MAX_IMAGES_BYTES
        else:
            max_count, max_bytes = 1, MAX_VIDEO_BYTES

        if not isinstance(keys, list) or not 1 <= len(keys) <= max_count:
            return JsonResponse({"error": "invalid_keys"}, status=400)

        err = _check_keys(user, keys, max_bytes)
        
        if err:
            return JsonResponse({"error": err}, status=400)

    with transaction.atomic():
        work = Work.objects.create(
            user=user,
            title=title,
            work_type=work_type,
            work_detail=work_detail,
        )

        if work_type == 1:
            Work_char.objects.create(work=work, main=text)

        elif work_type == 2:
            for n, key in enumerate(keys, start=1):
                Work_image.objects.create(
                    work=work,
                    main=key,
                    image_number=n
                )

        else:
            Work_movie.objects.create(
                work=work,
                main=keys[0]
            )

    print("creatework dekita")
    return JsonResponse({"id": work.id}, status=201)
