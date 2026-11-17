from django.http import JsonResponse
from community.models import Community

def communityMenuView(request):
    communityData= Community.objects.filter(pk=1)
    return JsonResponse({
        "community":list(communityData.values)
    })