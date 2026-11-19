# accounts/views/followView.py
import json
import logging
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import Follow, User
from core.firebase import verify_id_token

logger = logging.getLogger(__name__)

# アプリからのPOST通信を受け付ける
@csrf_exempt
@require_POST
def followView(request, user_id):
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

    # 送信相手のトークンを検証
    target = User.objects.filter(user_id=user_id).first()
    if target is None:
        return JsonResponse({"error": "user_not_found"}, status=404)
    if target.pk == me.pk:
        return JsonResponse({"error": "cannot_follow_self"}, status=400)

    # Jsonの情報を取得
    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)
    want = body.get("follow")
    if not isinstance(want, bool):
        return JsonResponse({"error": "invalid_follow"}, status=400)

    # 同じ操作を2回しても同じ結果になるように
    if want:
        Follow.objects.get_or_create(from_user=me, to_user=target)
    else:
        Follow.objects.filter(from_user=me, to_user=target).delete()

    # フォローできたかどうかと新しいフォロー数を取得
    return JsonResponse({
        "is_following": want,
        "follower_count": Follow.objects.filter(to_user=target).count(),
    })