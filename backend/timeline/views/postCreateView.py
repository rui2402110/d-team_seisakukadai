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
# 投稿の制限
MAX_IMAGES = 4
MAX_IMAGES_BYTES = 10 * 1024 * 1024
MAX_VIDEO_BYTES = 200 * 1024 * 1024


def _check_keys(user, keys, max_bytes):
    s3 = s3_client()
    prefix = f"posts/{user.pk}/"

    for key in keys:
        if not isinstance(key, str) or not key.startswith(prefix):
            return "invalid_key"

        try:
            head = s3.head_object(
                Bucket=bucket_name("posts"),
                Key=key
            )
        except ClientError:
            return "file_not_uploaded"

        if head["ContentLength"] > max_bytes:
            return "file_too_large"

    return None


@csrf_exempt
@require_POST
def postCreateView(request):

    header = request.headers.get("Authorization", "")

    if not header.startswith("Bearer "):
        return JsonResponse({"error": "no_token"}, status=401)

    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        logger.exception("verify_id_token_failed")
        return JsonResponse({"error": "invalid_token"}, status=401)

    user = User.objects.filter(firebase_uid=uid).first()

    if user is None:
        return JsonResponse({"error": "user_not_found"}, status=404)

    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)

    community_id = body.get("community_id")
    text = (body.get("post") or "").strip()
    reply_id = body.get("reply_id")
    keys = body.get("keys") or []
    media_type = body.get("media_type")

    if not community_id:
        return JsonResponse({"error": "community_required"}, status=400)

    if not text:
        return JsonResponse({"error": "empty_post"}, status=400)

    try:
        # コミュニティが存在するか確認
        community = Community.objects.get(
            id=community_id
        )
    except Community.DoesNotExist:
        return JsonResponse({"error": "community_not_found"}, status=404)

    reply_post = None

    if media_type not in (
        PostMedia.IMAGE,
        PostMedia.VIDEO,
        None,
    ):
        return JsonResponse(
            {"error": "invalid_media_type"},
            status=400
        )

    if reply_id:
        try:
            reply_post = Post.objects.get(id=reply_id)
        except Post.DoesNotExist:
            return JsonResponse({"error": "reply_not_found"}, status=404)

    if keys:

        if len(keys) > MAX_IMAGES:
            return JsonResponse({"error": "too_many_files"}, status=400)

        err = _check_keys(
            user,
            keys,
            MAX_VIDEO_BYTES
        )

        if err:
            return JsonResponse({"error": err}, status=400)

    with transaction.atomic():

        post = Post.objects.create(
            user=user,
            community=community,
            post=text,
            reply=reply_post,
        )

        for n, key in enumerate(keys, start=1):

            PostMedia.objects.create(
                post=post,
                media=key,
                mediaType=media_type,
                mediaNumber=n,
            )

        if reply_post:
            reply_post.replyCount += 1
            reply_post.save(update_fields=["replyCount"])

    return JsonResponse(
        {"id": post.id},
        status=201
    )