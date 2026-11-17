from django.urls import path
from .views import userProfileView

urlpatterns = [
    # 1. user_id が指定されない場合（自分のプロフィールを取得）
    path("userprofiles/", userProfileView, name="my_profile"),
    
    # 2. user_id が指定される場合（指定したユーザーのプロフィールを取得）
    path("userprofiles/<str:user_id>/", userProfileView, name="user_profile"),
]