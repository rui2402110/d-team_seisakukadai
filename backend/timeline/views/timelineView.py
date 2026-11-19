from django.http import JsonResponse
from django.views.decorators.http import require_GET

from timeline.models import Post, PostLikes


@require_GET
def timelineView(request):

    posts = Post.objects.select_related(
        "user",
        "community"
    ).order_by("-createdAt")[:20]

    result = []

    for post in posts:

        result.append({
            "post_id": post.pk,
            "name": post.user.name,
            "icon_url": post.user.icon_url,
            "community_name": post.community.name,
            "post": post.post,
            "like": post.like,
            "reply_count": post.replyCount,
            "created_at": post.createdAt,
        })

    return JsonResponse(result, safe=False)