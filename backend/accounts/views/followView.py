from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from .models import Follow

User = get_user_model()

@api_view(['POST'])                  # POSTメソッドのみ許可
@permission_classes([IsAuthenticated]) # ログインユーザーのみ許可
def toggle_follow(request, user_id):
    # フォローするユーザーを取得
    target_user = get_object_or_404(User, user_id=user_id)
    
    if request.user == target_user:
        return Response(
            {"error": "自分自身をフォローすることはできません。"}, 
            status=status.HTTP_400_BAD_REQUEST
        )

    # 既存のフォロー関係を検索
    follow_relation = Follow.objects.filter(
        from_user=request.user, 
        to_user=target_user
    )

    if follow_relation.exists():
        # フォロー解除
        follow_relation.delete()
        return Response(
            {"status": "unfollowed", "message": f"@{target_user.user_id} のフォローを解除しました。"}, 
            status=status.HTTP_200_OK
        )
    else:
        # フォロー
        Follow.objects.create(
            from_user=request.user, 
            to_user=target_user
        )
        return Response(
            {"status": "followed", "message": f"@{target_user.user_id} をフォローしました。"}, 
            status=status.HTTP_201_CREATED
        )