# core/storage.py
from django.conf import settings

def default_icon_url():
    """初期アイコンのURL。.envの ICON_STORAGE=local|s3 で切り替え。"""
    if settings.ICON_STORAGE == "s3":
        return f"https://{settings.AWS_S3_BUCKET}.s3.amazonaws.com/defaults/icon.png"
    return f"{settings.MEDIA_URL}defaults/icon.png"