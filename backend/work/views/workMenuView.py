import json
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from work.models import Work
from core.firebase import verify_id_token
from core.storage import default_icon_url

def workMenuView(request):
    # フォロー作品とおすすめ作品の代わりに初期データ参照
    recommendWork = Work.objects.filter(pk__in = [1,2,3])
    followWork = Work.objects.filter(pk__in = [1,2,3])
    return JsonResponse({
    "worked": True,
    "follow": list(followWork.values()),
    "recommend": list(recommendWork.values()),
})