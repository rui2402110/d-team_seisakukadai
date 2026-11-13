from django.db import models
from accounts.models import User
from community.models import Community
from django.conf import settings

# Create your models here.
class Post(models.Model):
    # userid
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="posts")
    community = models.ForeignKey(Community, on_delete=models.CASCADE, related_name="posts")
    post = models.CharField(max_length=255,default="")
    reply = models.ForeignKey('Post', on_delete=models.CASCADE, related_name="reply_posts",default=None,null=True, blank=True) 
    like = models.PositiveSmallIntegerField(default=0)
    replyCount = models.PositiveSmallIntegerField(default=0)
    createdAt = models.DateTimeField(auto_now_add=True)

class PostMedia(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="medias")
    media = models.CharField(max_length=1000)
    mediaNumber = models.PositiveSmallIntegerField(default=1)

    def __str__(self):
        return f"{self.post} - media {self.mediaNumber}"

class PostLikes(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="liked_posts")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="liked_users")
    createdAt = models.DateTimeField(auto_now_add=True)



