from django.http import JsonResponse
from usersettings.models import muteWord
#modelsのユーザーをインポート
from accounts.models import User
import logging

logger = logging.getLogger(__name__)


def muteWordView(request):
    # firebaseによる認証チェック
    header = request.headers.get("Authorization", "")

    if not header.startswith("Bearer"):
        return JsonResponse({"error": "no_token"}, status=401)
    
    try:
        # firebaseのIDトークンを検証
        uid = verify_id_token(header[7:])["uid"]
    
    except Exception:
        # トークン検証失敗
        logger.exception("verify_id_token feilled")
        return JsonResponse({"error": "invalid_token"}, status=401)

    # トークンのuid(firebase_uid)から、DBのユーザーを探す
    user = User.objects.filter(firebase_uid=uid).first()

    if user is None:
        # ユーザーが見つからない
        return JsonResponse({"error": "user_not_found"}, status=404)

    # ユーザーのミュートワードを取得
    muteWord = muteWord.objects.filter(user=user).all()
    
    return JsonResponse({"muteWord": muteWord.values()})
