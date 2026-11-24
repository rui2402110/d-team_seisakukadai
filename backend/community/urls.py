from django.urls import path
from community.views.communityMenuView import communityMenuView
from community.views.communityCreateView import communityCreateView
from community.views.communityDetailView import communityDetailView

urlpatterns = [
    path("communitymenu/",communityMenuView, name="communitymenu"),
    path("communitycreate/",communityCreateView,name="communitycreate"),
    path("communitydetail/<int:pk>/", communityDetailView, name="communitydetail"),
]
