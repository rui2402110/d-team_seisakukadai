from django.urls import path
from timeline.views.timelineView import timelineView, myCommunityView

urlpatterns = [
    path("timeline/", timelineView, name="timeline"),
    path("my-community/", myCommunityView, name="mycommunity"),
]

