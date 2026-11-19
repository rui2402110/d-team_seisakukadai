from django.urls import path
from timeline.views.timelineView import timelineView

urlpatterns = [
    path("timeline/", timelineView, name="timeline"),
]

