# accounts/views/loginView.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from accounts.models import User
from core.firebase import verify_id_token


@csrf_exempt
@require_POST
def loginView(request):
    # IDトークンを検証し、登録済みかどうかとユーザー情報を返す。
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return JsonResponse({"error": "no_token"}, status=401)
    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        return JsonResponse({"error": "invalid_token"}, status=401)

    user = User.objects.filter(firebase_uid=uid).first()
    if user is None:
        # Firebaseにはあるが、DBにいない → Flutter側で登録画面へ誘導する
        return JsonResponse({"registered": False}, status=200)

    return JsonResponse({
        "registered": True,
        "user": {
            "user_id": user.user_id, "name": user.name, "bio": user.bio,
            "link": user.link, "icon_url": user.icon_url,
            "created_at": user.created_at.isoformat(),
        },
    })
