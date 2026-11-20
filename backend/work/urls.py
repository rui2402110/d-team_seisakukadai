from django.urls import path
from work.views.workMenuView import workMenuView
from work.views.workDetailView import workDetailView
from work.views.workLikeView import workLikeView
from work.views.workPostView import workPostView
from work.views.uploadUrlView import uploadUrlView
from work.views.workCreateView import workCreateView

urlpatterns = [
    path("workmenu/", workMenuView, name="workmenu"),
    path("workdetail/<int:workid>/",workDetailView,name="work_detail"),
    path("worklike/<int:workid>/", workLikeView,name="work_like"),
    path("workpost/",workPostView, name="workpost"),
    path("uploadurl/",uploadUrlView, name="uploadurl"),
    path("workcreate/",workCreateView, name="workcreate"),
    
    

]

