from django.urls import path
from usersettings.views.muteWordView import muteWordView

urlpatterns = [
    # ミュートワード一覧を取得
    path('muteword/', muteWordView, name='muteword'),
]