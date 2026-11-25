from django.http import JsonResponse
from django.views.decorators.http import require_GET
import logging
from timeline.models import Post, PostLikes
from community.models import CommunityMember
from core.firebase import verify_id_token
from accounts.models import User
from core.storage import bucket_name
# ロガーの初期化（例外ログ出力用）
logger = logging.getLogger(__name__)

# 全コミュニティの投稿20件取得
@require_GET
def timelineView(request,post_id=None):
    # ログインユーザー取得
    header = request.headers.get("Authorization", "")
    me = None

    if header.startswith("Bearer "):
        try:
            uid = verify_id_token(header[7:])["uid"]
            me = User.objects.filter(firebase_uid=uid).first()
        except Exception:
            logger.exception("verify_id_token")

    #投稿取得
    if post_id is None:
        # TL
        posts = Post.objects.select_related(
            "user",
            "community"
        ).prefetch_related(
            "medias"
        ).filter(
            reply__isnull=True
        ).order_by("-createdAt")[:20]

    else:
        # 返信
        posts = Post.objects.select_related(
            "user",
            "community"
        ).prefetch_related(
            "medias"
        ).filter(
            reply_id=post_id
        ).order_by("createdAt")


    #いいね済投稿id取得

    liked_post_ids = set()

    if me:
        liked_post_ids = set(
            PostLikes.objects.filter(
                user=me,
                post_id__in=[post.pk for post in posts]
            ).values_list(
                "post_id",
                flat=True
            )
        )


    result = []

    for post in posts:

        medias = []

        for media in post.medias.all():
            print("めでぃあ"+media.media)
            medias.append({
                "media": f"https://{bucket_name('posts')}.s3.amazonaws.com/{media.media}",
                # "media":media.media,
                "media_type": media.mediaType,
                "media_number": media.mediaNumber,
            })

        result.append({
            "post_id": post.pk,
            "user_id": post.user.pk,
            "name": post.user.name,
            "icon_url": post.user.icon_url,
            "community_id": post.community.pk,
            "community_name": post.community.name,
            "post": post.post,
            "like": post.like,
            "is_liked": post.pk in liked_post_ids,
            "reply_id": post.reply.pk if post.reply is not None else 0,
            "reply_count": post.replyCount,
            "created_at": post.createdAt,
            "medias":medias
        })

    return JsonResponse(result, safe=False)

# 参加コミュニティ取得
@require_GET
def myCommunityView(request):
    # 1. Authorizationヘッダーの取得とプレフィックス確認
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):  
        return JsonResponse({"error": "no_token"}, status=401)

    # 2. Firebase IDトークンの検証
    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        logger.exception("verify_id_token")  
        return JsonResponse({"error": "invalid_token"}, status=401)

    # 3. リクエスト送信者（自分）をDBから取得
    me = User.objects.filter(firebase_uid=uid).first()
    if me is None:
        return JsonResponse({"error": "user_not_found"}, status=404)

    comlist = CommunityMember.objects.select_related(
        'community'
    ).filter(
        user = me
    )

    res = []

    for member in comlist:
        res.append({
            "community_id":member.community.pk,
            "name":member.community.name,
            "icon_url":member.community.icon_url,
            "is_favorite":member.is_favorite,
        })

    # safe=False:リストを返せるようにする
    return JsonResponse(res, safe=False)
