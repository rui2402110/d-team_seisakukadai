from django.http import JsonResponse
from community.models import Community

def communityMenuView(request):
    # objects.fillter = select
    # pk = コミュニティID
    # communityData = コミュニティ型の変数
    communityData = Community.objects.filter(pk=1)
    # JsonResponse = jsonで返り値を返す
    return JsonResponse({
        "community":list(communityData.values())
    })