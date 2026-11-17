import json
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from work.models import Work ,Work_like,Work_relation,Work_image,Work_char,Work_movie
from core.firebase import verify_id_token
from core.storage import default_icon_url


def workDetailView(request,workid):
    work = Work.objects.filter(pk = workid).first()
    like_count = Work_like.objects.filter(work=work).count()
    workRelation = Work_relation.objects.filter(pk = workid).first()
    
    match work.work_type:
        case 1:
            workMain = Work_char.objects.filter(work_id = workid).first()
        case 2:
            workMain = Work_image.objects.filter(work_id = workid).first()
        case 3:
            workMain = Work_movie.objects.filter(work_id = workid).first()

    return JsonResponse({
    "pk": workid,
    "fields": {
      "user": work.user.name,
      "title": work.title,
      "work_type": work.work_type,
      "work_detail": work.work_detail,
      "created_at": work.created_at,
    },
    "likecount": like_count,
    "relation": workRelation,
    "Main" : workMain.main,
    })


