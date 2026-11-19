# core/storage.py
import boto3
from botocore.config import Config
from django.conf import settings

# 初期アイコン
def default_icon_url():
    """初期アイコンのURL。.envの ICON_STORAGE=local|s3 で切り替え。"""
    if settings.ICON_STORAGE == "s3":
        return f"https://{settings.AWS_S3_BUCKET}.s3.amazonaws.com/defaults/icon.png"
    return f"{settings.MEDIA_URL}defaults/icon.png"


# S3
def _region():
    """バケットのあるリージョン。.env の AWS_S3_REGION で変えられる(なければ東京)。"""
    return getattr(settings, "AWS_S3_REGION", "ap-northeast-1")


def s3_client():
    # 鍵は.envから読み込む
    return boto3.client(
        "s3",
        region_name=_region(),
        config=Config(signature_version="s3v4"),
    )


def media_url(key):
    # DBに保存してある key(例: works/1/abc.png)から、表示用のURLを作る。
    return (
        f"https://{settings.AWS_S3_BUCKET}.s3."
        f"{_region()}.amazonaws.com/{key}"
    )