from django.http import JsonResponse #返す用
from ..models import Follow,User
from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404

@login_required
def followView(request,to_id):
    # post以外弾く
    if request.method != 'POST':
        return JsonResponse({
            "status": "error",
            "message": "無効なリクエストメソッドです。"
        }, status=405)
    
    # フォローする側のID
    from_user = request.user

    # 存在確認
    to_user = get_object_or_404(User, pk=to_id)
    # 自分自身のフォローは弾く
    if from_user.id == to_user.id:
        return JsonResponse({
            "status":"error",
            "message":"自分自身をフォローできません"
        }, status=400)

    # 既存のフォロー関係を検索 
    existing_follow = Follow.objects.filter(
        from_user = from_user,
        to_user = to_user
    )

    if request.method == 'POST':
        # フォロー解除
        if existing_follow.exists():
            existing_follow.delete()
            return JsonResponse({
                "status":"success",
                "message":f"{to_user.name}のフォローを解除しました",
                "is_following":False,
            })
        else:
            Follow.objects.create(
                from_user = from_user,
                to_user = to_user
            )
            return JsonResponse({
                "status":"success",
                "message":f"{to_user.name}のフォローしました",
                "is_following":True,
            })


    