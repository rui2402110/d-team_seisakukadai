# core/storage.py
import boto3
from botocore.config import Config
from django.conf import settings


# ==================================================
# バケットの名前を、用途から引く
#   "works" : 作品(画像・動画)   → AWS_S3_BUCKET_WORKS
#   "posts" : 投稿(タイムライン) → AWS_S3_BUCKET_POSTS
#   "icons" : アイコン           → AWS_S3_BUCKET_ICONS
# バケット名は、config/settings.py(.env)で決める。コードには書かない。
# ==================================================
def bucket_name(purpose):
    names = {
        "works": settings.AWS_S3_BUCKET_WORKS,
        "posts": settings.AWS_S3_BUCKET_POSTS,
        "icons": settings.AWS_S3_BUCKET_ICONS,
    }
    # 知らない用途を渡したら、気づけるように、エラーにする
    if purpose not in names:
        raise ValueError(f"unknown bucket purpose: {purpose}")
    return names[purpose]


def _region():
    """バケットのあるリージョン。.env の AWS_S3_REGION で決める。"""
    return getattr(settings, "AWS_S3_REGION", "us-east-1")


def s3_client():
    """S3を操作するための窓口。鍵は、環境変数か ~/.aws/credentials から自動で読まれる。"""
    return boto3.client(
        "s3",
        region_name=_region(),
        config=Config(
            signature_version="s3v4",
            # 署名付きURLのホスト名を、リージョン付きの形に統一する
            s3={"addressing_style": "virtual"},
        ),
    )


def media_url(purpose, key):
    """DBに保存してある key から、表示用のURLを作る。

    使い方: media_url("works", "works/1/abc.png")
    注意: 非公開のバケットでは、このURLでは表示できない(公開読み取りが必要)。
    """
    return f"https://{bucket_name(purpose)}.s3.{_region()}.amazonaws.com/{key}"


# ==================================================
# 初期アイコン(icons バケットの defaults/icon.png を使う)
# ==================================================
def default_icon_url():
    """初期アイコンのURL。.envの ICON_STORAGE=local|s3 で切り替え。"""
    if settings.ICON_STORAGE == "s3":
        return media_url("icons", "defaults/icon.png")
    return f"{settings.MEDIA_URL}defaults/icon.png"