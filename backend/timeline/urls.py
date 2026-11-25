from django.urls import path
from timeline.views.timelineView import timelineView, myCommunityView
from timeline.views.likeView import LikeView
from timeline.views.postCreateView import postCreateView
from timeline.views.uploadUrlView import uploadUrlView
urlpatterns = [
    path("timeline/", timelineView, name="timeline"),
    path("timeline/<str:post_id>/", timelineView, name="timelinepost"),
    path("my-community/", myCommunityView, name="mycommunity"),
    path("like/", LikeView, name="like"),
    path("postcreate/",postCreateView, name="postcreate"),
    path("uploadurls/",uploadUrlView, name="postuploadurls"),
]

