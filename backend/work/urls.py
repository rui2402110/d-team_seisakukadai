from django.urls import path
from work.views.workMenuView import workMenuView
from work.views.workDetailView import workDetailView

urlpatterns = [
    path("workmenu/", workMenuView, name="workmenu"),
]

from django.urls import path
from . import views

urlpatterns = [
    path(
        "workdetail/<int:workid>/",
        views.workDetailView,
        name="work_detail"
    ),
]