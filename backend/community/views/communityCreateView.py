from django.http import JsonResponse
from community.models import Community,CommunityMember
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import json
from accounts.models import User
from core.firebase import verify_id_token
import logging
from django.db import transaction


logger = logging.getLogger(__name__)

@csrf_exempt
@require_POST
def communityCreateView(request):
    header = request.headers.get("Authorization", "")

    if not header.startswith("Bearer"):
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
    name=body.get("name")
    target=body.get("target")
    detail=body.get("deteil","")
    icon_url=body.get("icon_url")
    
    with transaction.atomic():
        community = Community.objects.create(
        created_user=user,
        name=name,
        target=target,
        detail=detail,
        icon_url=icon_url,
        community_type=1,
        )
        CommunityMember.objects.create(
            community=community,
            user=user,
            authority=1,        # 1=ホスト
            is_favorite=False,
        )
    return JsonResponse({"id": community.id}, status=201)
