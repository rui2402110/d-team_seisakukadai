from django.db import models
from django.conf import settings

# Create your models here.
class MuteWord(models.Model):
    # ForeignKeyは、多対一の関係を表す。多はミュートワードであり、一はユーザー識別情報である。ユーザーIDとユーザー、その他情報が"ユーザー識別情報"としている。
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="mute_names")
    # 文字列型のカラム
    mute_word = models.CharField(max_length=100)
    # 日時型のカラム。自動で登録時の日時を設定
    created_at = models.DateTimeField(auto_now_add=True)