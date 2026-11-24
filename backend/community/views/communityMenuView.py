from django.http import JsonResponse
from community.models import Community

def communityMenuView(request):
    # objects.fillter = select
    # pk = コミュニティID
    # communityData = コミュニティ型の変数
    communityData =Community.objects.order_by('-id')[:3]
    # JsonResponse = jsonで返り値を返す
    return JsonResponse({
        "community":list(communityData.values())
    })