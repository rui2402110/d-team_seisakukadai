from django.http import JsonResponse
from django.db.models import Count
from community.models import Community


def communityDetailView(request, pk):
    # コミュニティ詳細を1件返す（存在しなければ404）
    c = (
        Community.objects.filter(pk=pk)
        .select_related("created_user")
        .annotate(member_count=Count("members"))
        .first()
    )
    if c is None:
        return JsonResponse({"error": "community_not_found"}, status=404)

    return JsonResponse({
        "id": c.pk,
        "name": c.name,
        "target": c.target,
        "detail": c.detail,
        "icon_url": c.icon_url,
        "created_at": c.created_at.strftime("%Y/%m/%d"),
        "community_type": c.community_type,
        "member_count": c.member_count,
        "host": {
            "user_id": c.created_user.user_id,
            "name": c.created_user.name,
            "icon_url": c.created_user.icon_url,
        },
    })
