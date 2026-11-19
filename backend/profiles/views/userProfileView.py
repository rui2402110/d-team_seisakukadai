import json
import logging
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET
from accounts.models import User,Follow
from core.firebase import verify_id_token
from core.storage import default_icon_url

# ロガーの初期化（例外ログ出力用）
logger = logging.getLogger(__name__)

@require_GET
def userProfileView(request, user_id=None):
    # 1. Authorizationヘッダーの取得とプレフィックス確認
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer"):  
        return JsonResponse({"error": "no_token"}, status=401)

    # 2. Firebase IDトークンの検証
    try:
        uid = verify_id_token(header[7:])["uid"]
    except Exception:
        logger.exception("verify_id_token")  
        return JsonResponse({"error": "invalid_token"}, status=401)

    # 3. リクエスト送信者（自分）をDBから取得
    me = User.objects.filter(firebase_uid=uid).first()
    if me is None:
        return JsonResponse({"error": "user_not_found"}, status=404)
    
    # 4. 取得対象ユーザーの判定（user_idがなければ自分、あれば指定されたユーザー）
    # ※ 引数名を userId から user_id に統一
    if user_id is None:
        target = me
    else:
        target = User.objects.filter(user_id=user_id).first()
        if target is None:
            return JsonResponse({"error": "user_not_found"}, status=404)
    # フォローしているか
    is_follow = Follow.objects.filter(from_user=me,to_user=target).exists()
    # フォロー数（自分がフォローしている人数）
    follow_count = Follow.objects.filter(
        from_user=target
    ).count()
    # フォロワー数（自分をフォローしている人数）
    follower_count = Follow.objects.filter(
        to_user=target
    ).count()
            
    # 5. プロフィール情報と自分かどうかのフラグを返却
    return JsonResponse({
        "user": {
            "user_id": target.user_id,
            "name": target.name,
            "bio": target.bio,
            "link": target.link,
            "icon_url": target.icon_url,
            "created_at": target.created_at.isoformat(),
            "is_follow":is_follow,
            'follow_count':follow_count,
            'follower_count':follower_count,
        },
        "is_me": (target.pk == me.pk),
    })