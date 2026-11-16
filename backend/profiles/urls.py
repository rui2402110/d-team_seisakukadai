from django.urls import path
from profiles.views.userProfileView import userProfileView  # フォルダ名は実際のアプリ名に合わせてください

urlpatterns = [
    path("userprofiles/<str:user_id>/", userProfileView, name="user_profile"),
]