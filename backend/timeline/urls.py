from django.urls import path
from timeline.views.timelineView import timelineView, myCommunityView
from timeline.views.likeView import LikeView

urlpatterns = [
    path("timeline/", timelineView, name="timeline"),
    path("timeline/<str:post_id>/", timelineView, name="timelinepost"),
    path("my-community/", myCommunityView, name="mycommunity"),
    path("like/", LikeView, name="like"),
]

