import os
from django.http import JsonResponse
from work.models import Work, Work_like, Work_relation, Work_image, Work_char, Work_movie
from accounts.models import User
from core.firebase import verify_id_token


def workDetailView(request, workid):
    # ---------- ユーザーの取得 ----------
    # Authorization: Bearer <Firebase IDトークン> からログイン中ユーザーを特定する
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        return JsonResponse({"error": "認証トークンがありません"}, status=401)

    try:
        decoded = verify_id_token(auth.split(" ", 1)[1])
    except Exception:
        return JsonResponse({"error": "トークンが無効です"}, status=401)

    user = User.objects.filter(firebase_uid=decoded["uid"]).first()
    if user is None:
        return JsonResponse({"error": "ユーザーが見つかりません"}, status=404)

    # ---------- 作品の取得 ----------
    work = Work.objects.select_related("user").filter(pk=workid).first()
    if work is None:
        return JsonResponse({"error": "作品が見つかりません"}, status=404)

    # ---------- いいね ----------
    likes = Work_like.objects.filter(work=work)

    # ---------- 関連作品 ----------
    relations = Work_relation.objects.filter(work=work).select_related(
        "relation_work__user"
    )
    relation_list = [
        {
            "pk": r.relation_work.pk,
            "title": r.relation_work.title,
            "user": r.relation_work.user.name,
        }
        for r in relations
    ]

    # ---------- 作品本体(タイプごと) ----------
    match work.work_type:
        case 1:  # 文字: 本文(文字列)
            obj = Work_char.objects.filter(work=work).first()
            main = obj.main if obj else ""
        case 2:  # 画像: [{"main": URL}, ...] を image_number 順で返す
            bucket = os.environ.get('AWS_S3_BUCKET_WORKS', '')
            main = [
                {"main": f"https://{bucket}.s3.amazonaws.com/{img.main}"}
                for img in Work_image.objects.filter(work=work).order_by("image_number")
            ]
        case 3:  # 動画: URL(文字列)
            obj = Work_movie.objects.filter(work=work).first()
            main = obj.main if obj else ""
        case _:
            main = ""

    return JsonResponse({
        "pk": work.pk,
        "fields": {
            "user": work.user.name,
            "title": work.title,
            "work_type": work.work_type,
            "work_detail": work.work_detail,
            "created_at": work.created_at,
        },
        "likecount": likes.count(),
        "liked": likes.filter(user=user).exists(),
        "relation": relation_list,
        "Main": main,
    })
