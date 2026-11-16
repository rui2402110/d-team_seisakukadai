# import json
# from django.db import IntegrityError
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# from django.views.decorators.http import require_POST
# from work.models import Work ,Work_like,Work_relation,Work_image,Work_char,Work_movie
# from core.firebase import verify_id_token
# from core.storage import default_icon_url


# def workDetailView(request,workid):
#     work = Work.objects.filter(pk = workid)
#     workLike = Work_like.objects.filter(pk = workid)
#     workRelation = Work_relation.objects.filter(pk = workid)
    
#     match work.work_type:
#         case 1:
#             workMain = Work_char.object.filter(pk = workid)
#         case 2:
#             workMain = Work_image.object.filter(pk = workid)
#         case 3:
#             workMain = Work_movie.object.filter(pk = workid)

#     return JsonResponse({
#     "pk": workid,
#     "fields": {
#       "user": work.user.name,
#       "title": work.title,
#       "work_type": work.work_type,
#       "work_detail": work.work_detail,
#       "created_at": work.created_at,
#     },
#     "likecount": workLike.count(),
#     "relation": workRelation,
#     "Main" : workMain.main,
#     })


from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.decorators.http import require_GET

from work.models import (
    Work,
    Work_like,
    Work_relation,
)


@require_GET
def workDetailView(request, workid):
    """
    作品詳細情報を取得するView
    """

    # 作品を1件取得
    work = get_object_or_404(
        Work.objects.select_related("user"),
        pk=workid
    )

    # いいね数を取得
    like_count = Work_like.objects.filter(
        work=work
    ).count()

    # 関連作品を取得
    relation_qs = Work_relation.objects.filter(
        work=work
    ).select_related(
        "relation_work",
        "relation_work__user"
    )

    relation = []

    for item in relation_qs:
        related_work = item.relation_work

        relation.append({
            "pk": related_work.pk,
            "title": related_work.title,
            "user": str(related_work.user),
            "work_type": related_work.work_type,
        })

    # 作品タイプに応じて本文などを取得
    main = None

    # 文字作品
    if work.work_type == 1:
        if hasattr(work, "char"):
            main = work.char.main
        else:
            main = ""

    # 画像作品
    elif work.work_type == 2:
        main = list(
            work.images.order_by("image_number").values(
                "id",
                "main",
                "image_number"
            )
        )

    # 動画作品
    elif work.work_type == 3:
        if hasattr(work, "movie"):
            main = work.movie.main
        else:
            main = ""

    # FlutterにJSONを返す
    return JsonResponse({
        "pk": work.pk,

        "fields": {
            "user": str(work.user),
            "title": work.title,
            "work_type": work.work_type,
            "work_detail": work.work_detail,
            "created_at": work.created_at.isoformat(),
        },

        "likecount": like_count,

        "relation": relation,

        "Main": main,
    })