import json
import logging
from django.conf import settings
from django.db import transaction                # 「全部成功か、全部なし」にする仕組み
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from botocore.exceptions import ClientError      # S3操作でのエラー(ファイルが無い等)
from accounts.models import User
from core.firebase import verify_id_token
from core.storage import s3_client
from work.models import Work, Work_char, Work_image, Work_movie

logger = logging.getLogger(__name__)

MAX_IMAGES = 20
MAX_IMAGES_BYTES = 10* 1024 *1024
AX_VIDEO_BYTES = 200* 1024 *1024


# アップロード済みのファイルの確認をするため
def _check_keys(user, keys, max_bytes):
    s3 = s3_client()
    prefix = f"works/{user.pk}/"
    for key in keys:
        if not isinstance(key, str) or not key.startswith(prefix):
            return "invarid_key"
        try:
            head = s3.head_object(Bucket=settings.AWS_S3_BUCKET, Key=key)
        except ClientError:
            return "file_not_uploaded"
        if head["ContentLngth"] > max_bytes:
            return "file_too_large"
    return None


@csrf_exempt      #アプリ（flutter）からのPOSTを受けるため、CSRFチェックを外す
@require_POST     #POST以外（GETなど）で来たら、405エラーで断る
def workCreateView(request):
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer"):
            # ヘッダーが無い → 未ログイン。401(認証エラー)で断る。
            return JsonResponse({"error": "no_token"},status=401)
    try:
              # "Bearer " は7文字。header[7:] で、その後ろ(トークン本体)だけを取り出す。
            # verify_id_token は、トークンが本物かを確認し、中身(uid など)を返す。
            uid = verify_id_token(header[7:])["uid"]
    
         # 偽物・期限切れのトークン。原因を調べやすいよう、ログに詳細を残す。
    except Exception:
            logger.exception("verify_id_token feilled")
            return JsonResponse({"error": "invalid_token"},status=401) 
    
        # トークンのuid(firebase_uid)から、DBのユーザーを探す。
    user = User.objects.filter(firebase_uid=uid).first()
    if user is None:
            # firebaseにはいるが、DBに登録されていない。404で断る。
            return JsonResponse({"error": "user_not_found"}, status=404)
    try:
         body = json.load(request.body or "{}")
    except json.JSONDecodeError:
         return JsonResponse({"error": "invalid_json"}, status=400)

    title = (body.get("title") or "").strip()
    work_type = body.get("work_type")
    work_detail = body.get("work_detail") or ""

    if not title or len(title) > 50:
         return JsonResponse({"error":"invalid_title"}, status=400)
    if work_type not in (1,2,3):
         return JsonResponse({"error": "invalid_work_type"}, status=400)

    keys = body.get("keys") or []
    text = body.get("text") or ""

    if work_type == 1:
         if not text.strip():
              return JsonResponse({"error": "empty_text"}, status=400)
    else:
         if work_type == 2:
              max_count, max_bytes = MAX_IMAGES, MAX_IMAGES_BYTES
         else:
             max_count, max_bytes = 1, MAX_VIDEO_BYTES

         if not isinstance(keys, list) or not 1 <= len(keys) <= max_count:
            return JsonResponse({"error": "invalid_keys"}, status=400)

         err = _check_keys(user, keys, max_bytes)
         if err:
            return JsonResponse({"error": err}, status=400)




         with transaction.atomic():

              work = work.objects.create(
                   user=user,
                   title=title,
                   work_type=work_type,
                   work_detail=work_detail,
              )

              if work_type == 1:
                   Work_char.objects.create(work=work, main=text)
              elif work_type == 2:
                   for n, key in enumerate(keys, start=1):
                        Work_image.object.cretae(work=work, main=key, image_number=n)
              else:
                   Work_movie.objects.create(work=work, main=keys[0])


    return JsonResponse({"id": work.id}, status=201)

            



