from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models
def get_deleted_user():
    # 退会済みのユーザーを設定
    user, _ = get_user_model().objects.get_or_create(
        firebase_uid="deleted-user",
        defaults={"name": "test"},
    )
    return user

# コミュニティ
class Community(models.Model):

    name = models.CharField(max_length=50)
    target = models.CharField(max_length=100, blank=True, default="")
    detail = models.TextField(blank=True, default="") 
    icon_url = models.CharField(max_length=1000, blank=True, default="")
    created_at = models.DateField(auto_now_add=True)
    created_user = models.ForeignKey(
       settings.AUTH_USER_MODEL,
       # ユーザーが消えた際、代替のものを用意する関数を配置
       on_delete=models.SET(get_deleted_user),
       related_name="created_communities",
    )
    # 1=オープン。現在オープンのみのため1固定
    community_type = models.SmallIntegerField(max_length=2)

    class Meta:
        ordering = ["-created_at"]


# コミュニティの参加者
class CommunityMember(models.Model):

    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="members")
    user = models.ForeignKey(settings.AUTH_USER_MODEL,on_delete=models.CASCADE,related_name="community_memberships",)
    created_at = models.DateTimeField(auto_now_add=True)
    # 権限 1=ホスト,2=一般
    authority = models.SmallIntegerField(max_length=10)
    is_favorite = models.BooleanField()

    class Meta:
        #  同じ人が同じコミュニティに2回入らないようにする
        constraints = [models.UniqueConstraint(fields=["community", "user"], name="uniq_community_member")]
