from django.urls import path
from work.views.workMenuView import workMenuView

urlpatterns = [
    path("workmenu/", workMenuView, name="workmenu"),
]
