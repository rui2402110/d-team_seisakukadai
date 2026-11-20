from django.urls import path
from community.views.communityMenuView import communityMenuView
from community.views.communityCreateView import communityCreateView

urlpatterns = [
    path("communitymenu/",communityMenuView, name="communitymenu"),
    path("communitycreteview/",communityCreateView,name="communitycreateview")
]