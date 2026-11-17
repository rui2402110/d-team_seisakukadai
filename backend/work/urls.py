from django.urls import path
from work.views.workMenuView import workMenuView
from work.views.workDetailView import workDetailView

urlpatterns = [
    path("workmenu/", workMenuView, name="workmenu"),
     path("workdetail/<int:workid>/",workDetailView,name="work_detail"),
]

