from django.db import models
from accounts.models import User
from community.models import Community

# Create your models here.
class Post(models.Model):
    # userid
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="post")
    community = models.ForeignKey(settings.COMMUNITY, on_delete=models.CASCADE, related_name="post")
    post = models.CharField()
    reply = models.PositiveSmallIntegerField(default=0)
    like = models.PositiveSmallIntegerField(default=0)
    createdAt = models.DateTimeField(auto_now_add=True)

class PostMedia(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="images")
    image = models.ImageField(upload_to='post/images/')
    imageNumber = models.PositiveSmallIntegerField(default=1)

    def __str__(self):
        return f"{self.post} - image {self.imageNumber}"

class PostLikes(models.Model):
    post = models.OneToOneField(Post, on_delete=models.CASCADE, related_name="likes")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="post")
    createdAt = models.DateTimeField(auto_now_add=True)



