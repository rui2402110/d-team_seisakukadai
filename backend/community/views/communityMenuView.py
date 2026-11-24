from django.db.models import Count
from django.http import JsonResponse
from community.models import Community

def communityMenuView(request):
    # objects.fillter = select
    # pk = コミュニティID
    # communityData = コミュニティ型の変数
    communities = (
        Community.objects
        .annotate(member_count=Count("members"))   # 参加者数を集計
        .order_by("-id")[:3]
    )
    # JsonResponse = jsonで返り値を返す
    return JsonResponse({
        "community": [
            {
                "id": c.id,
                "name": c.name,
                "target": c.target,
                "detail": c.detail,
                "icon_url": c.icon_url,
                "community_type": c.community_type,
                "member_count": c.member_count,
            }
            for c in communities
        ]
    })