# core/firebase.py
import os
import firebase_admin
from firebase_admin import auth, credentials


def _init():
    """初回だけFirebase Admin SDKを初期化する(起動時ではなく初回利用時)。"""
    if firebase_admin._apps:
        return
    # サービスアカウントのJSONのパスは環境変数で渡す(JSON自体はgitに入れない)
    path = os.environ.get("FIREBASE_CREDENTIALS")
    if not path:
        raise RuntimeError("環境変数 FIREBASE_CREDENTIALS が設定されていません")
    firebase_admin.initialize_app(credentials.Certificate(path))


def verify_id_token(token):
    """IDトークンを検証して、中身(uidなど)を返す。無効なら例外。"""
    _init()
    return auth.verify_id_token(token)
