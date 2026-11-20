# timeline/like.py
import json
import logging
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import User
from timeline.models import Post,PostLikes
from core.firebase import verify_id_token

logger = logging.getLogger(__name__)

# アプリからのPOST通信を受け付ける
@csrf_exempt
@require_POST
def LikeView(request):
    # トークン検証
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return JsonResponse({"error": "no_token"}, status=401)
    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        logger.exception("verify_id_token failed")
        return JsonResponse({"error": "invalid_token"}, status=401)
    me = User.objects.filter(firebase_uid=uid).first()
    if me is None:
        return JsonResponse({"error": "user_not_found"}, status=404)

    # Jsonの情報を取得
    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)
    post_id = body.get("postId")

    post = Post.objects.filter(
        pk = post_id
    ).first()

    if post is None:
         return JsonResponse({"error": "post_not_found"}, status=404)

    #いいね済か
    like = PostLikes.objects.filter(post= post, user=me).first()

    if like:
        # いいね解除
        like.delete()
        is_liked = False

    else:
        # いいね追加
        PostLikes.objects.create(
            post=post,
            user=me
        )
        is_liked = True

    # いいね数更新
    like_count = PostLikes.objects.filter(
        post=post
    ).count()

    post.like = like_count
    post.save(update_fields=["like"])

    return JsonResponse({
        "postId": post.pk,
        "isLiked": is_liked,
        "likeCount": like_count,
    })