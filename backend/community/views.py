# from django.shortcuts import render

# # Create your views here.


# 11/18 追加
from django.http import JsonResponse
from django.db.models import Count
from community.models import Community

def communityMenuView(request):
    communityData = Community.objects.annotate(
        member_count=Count("members")
    )

    return JsonResponse({
        "community": list(
            communityData.values(
                "id",
                "name",
                "target",
                "detail",
                "icon_url",
                "community_type",
                "member_count",
            )
        )
    })
