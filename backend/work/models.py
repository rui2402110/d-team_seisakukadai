from django.db import models
from django.conf import settings

# Create your models here.
class Work(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="works")
    title = models.CharField(max_length=50)

    class WorkType(models.IntegerChoices):
        char = 1,"文字"
        image = 2,"画像"
        movie = 3,"動画"
    work_type = models.PositiveBigIntegerField(choices=WorkType.choices)
    work_detail = models.TextField(default="")
    created_at = models.DateTimeField(auto_now_add=True) 

class Work_image(models.Model):
    work = models.ForeignKey(Work, on_delete=models.CASCADE, related_name="images")
    main = models.CharField(max_length=1000)
    image_number = models.PositiveBigIntegerField()

class Work_char(models.Model):
    work = models.OneToOneField(Work, on_delete=models.CASCADE, related_name="char")
    main = models.TextField(default="")

class Work_movie(models.Model):
    work = models.OneToOneField(Work, on_delete=models.CASCADE, related_name="movie")
    main = models.CharField(max_length=1000)

class Work_relation(models.Model):
    work = models.ForeignKey(Work, on_delete=models.CASCADE, related_name="relation")
    relation_work = models.ForeignKey(Work, on_delete=models.CASCADE, related_name="related_from")

class Work_like(models.Model):
    work = models.ForeignKey(Work, on_delete=models.CASCADE, related_name="like")
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="work_likes")
    liked_at = models.DateTimeField(auto_now_add=True)