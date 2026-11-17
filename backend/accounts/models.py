import uuid
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, firebase_uid, **extra):
        user = self.model(firebase_uid=firebase_uid, **extra)
        user.set_unusable_password()
        user.save(using=self._db)
        return user


class User(AbstractBaseUser):
    # 6. システム側で一意に決める公開用ID
    user_id = models.CharField(max_length=32, unique=True, editable=False)
    firebase_uid = models.CharField(max_length=128, unique=True)  # firebaseのuid
    name = models.CharField(max_length=50)
    bio = models.TextField(blank=True, default="")                # 初期値は空文字
    link = models.CharField(max_length=255, blank=True, default="")
    icon_url = models.CharField(max_length=500, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)          # 利用開始日

    USERNAME_FIELD = "user_id"
    objects = UserManager()

    def save(self, *args, **kwargs):
        if not self.user_id:
            self.user_id = uuid.uuid4().hex[:12]
        super().save(*args, **kwargs)

class Follow(models.Model):
    # フォローする側
    from_user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='following' 
    )
    # フォローされる側
    to_user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='follower' 
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        # 同じユーザーを二重にフォローできないようにする制約
        constraints = [
            models.UniqueConstraint(
                fields=['from_user', 'to_user'], 
                name='unique_follow')
        ]
        verbose_name = 'フォロー関係'
        verbose_name_plural = 'フォロー関係'

    def __str__(self):
        return f"{self.from_user.user_id} -> {self.to_user.user_id}"