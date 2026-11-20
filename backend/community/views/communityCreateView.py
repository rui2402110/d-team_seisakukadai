from django.http import JsonResponse
from community.models import Community
import json
from accounts.models import User
from core.firebase import verify_id_token
import logging
logger = logging.getLogger(__name__)


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
        body = json.load(request.body or "{}")

    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)
    name=body.get("name")
    target=body.get("target")
    datail=body.get("dateil")
    icon_url=body.get("icon_url")
    
            
    community = Community.objects.create(
    user=user,
    name=name,
    target=target,
    datail=datail,
    icon_url=icon_url,
    )
    return JsonResponse({"id": community.id}, status=201)
