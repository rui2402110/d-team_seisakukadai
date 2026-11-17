from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from work.models import Work, Work_like
from accounts.models import User
from core.firebase import verify_id_token


# GET : いいね情報の取得
# POST: いいねの切り替え(していなければ追加、していれば取り消し)
# 認証はFirebase IDトークン(Authorizationヘッダー)で行うため csrf_exempt にしている
@csrf_exempt
@require_http_methods(["GET", "POST"])
def workLikeView(request, workid):
    # ---------- ユーザーの取得 ----------
    # Authorization: Bearer <Firebase IDトークン> からログイン中ユーザーを特定する
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        return JsonResponse({"error": "認証トークンがありません"}, status=401)

    try:
        decoded = verify_id_token(auth.split(" ", 1)[1])
    except Exception:
        return JsonResponse({"error": "トークンが無効です"}, status=401)

    # Firebaseのuidから、自分のUserを取得する
    user = User.objects.filter(firebase_uid=decoded["uid"]).first()
    if user is None:
        return JsonResponse({"error": "ユーザーが見つかりません"}, status=404)

    # ---------- 作品の取得 ----------
    work = Work.objects.filter(pk=workid).first()
    if work is None:
        return JsonResponse({"error": "作品が見つかりません"}, status=404)

    # ---------- POST: いいねの切り替え ----------
    if request.method == "POST":
        mine = Work_like.objects.filter(work=work, user=user)
        if mine.exists():
            mine.delete()      # いいね済み → 取り消し
        else:
            Work_like.objects.create(work=work, user=user)  # 未いいね → 追加

    # ---------- いいね情報 ----------
    # この作品のいいね数 / ログイン中ユーザーがいいね済みか
    likes = Work_like.objects.filter(work=work)

    return JsonResponse({
        "pk": work.pk,
        "work": {
            "title": work.title,
            "work_type": work.work_type,
            "work_detail": work.work_detail,
            "created_at": work.created_at,
        },
        "user": {
            "user_id": user.user_id,
            "name": user.name,
        },
        "likecount": likes.count(),
        "liked": likes.filter(user=user).exists(),
    })
