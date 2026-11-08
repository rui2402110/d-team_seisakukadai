# accounts/views/registerView.py
import json
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import User
from core.firebase import verify_id_token
from core.storage import default_icon_url


@csrf_exempt
@require_POST
def registerView(request):
    # --- トークン検証(uid) ---
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return JsonResponse({"error": "no_token"}, status=401)
    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        return JsonResponse({"error": "invalid_token"}, status=401)

    # --- 入力値(bodyは表示名だけ) ---
    try:
        body = json.loads(request.body or "{}")
    except json.JSONDecodeError:
        return JsonResponse({"error": "invalid_json"}, status=400)
    name = (body.get("name") or "").strip()
    if not name or len(name) > 50:
        return JsonResponse({"error": "invalid_name"}, status=400)

    # --- すでに登録済みなら、そのまま成功として返す(やり直しに対応) ---
    existing = User.objects.filter(firebase_uid=uid).first()
    if existing:
        return JsonResponse({"user": _to_dict(existing)}, status=200)

    # --- 作成(user_id衝突時は数回やり直す) ---
    for _ in range(3):
        try:
            user = User.objects.create_user(
                firebase_uid=uid, name=name, icon_url=default_icon_url()
            )
            return JsonResponse({"user": _to_dict(user)}, status=201)
        except IntegrityError:
            if User.objects.filter(firebase_uid=uid).exists():  # 同時リクエスト対策
                user = User.objects.get(firebase_uid=uid)
                return JsonResponse({"user": _to_dict(user)}, status=200)
    return JsonResponse({"error": "create_failed"}, status=500)


def _to_dict(u):
    return {"user_id": u.user_id, "name": u.name, "bio": u.bio,
            "link": u.link, "icon_url": u.icon_url,
            "created_at": u.created_at.isoformat()}