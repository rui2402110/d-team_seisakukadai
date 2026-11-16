from django.urls import path
from Proflies.views.userProfileView import userProfileView 

uslpatterns = [
    path("userprofiles/",userProfileView,name="userprofiles"),
]