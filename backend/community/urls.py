from django.urls import path
from community.views.communityMenuView import communityMenuView

urlpatterns = [
    path("communitymenu/",communityMenuView, name="communitymenu")
]