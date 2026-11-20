# work/view/uploadUrlView.py

# この viewの役割は書名付きurlを発行する
# Flutter が「これからファイルをアップロードしたい」と伝えると、
#   「S3のこの場所に、5分間だけ、このファイルを置いてよい」という
#   一時的な許可証(署名付きURL)を、ファイルの数だけ作って返す。
#   ファイル本体は、この view を通らない(Flutter が S3 へ直接送る)。
#
# 【対象】 画像(work_type=2)と動画(work_type=3)だけ。
#          文字作品(work_type=1)は、S3を使わないので、この view は使わない。

import json
import logging
import uuid                                   # ファイル名を、重ならない名前にするため
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.conf import settings
from accounts.models import User
from core.firebase import verify_id_token     # Firebaseのトークンを検証する関数
from core.storage import s3_client,bucket_name  


logger = logging.getLogger(__name__)

# 許可するファイル形式。　｛Content-type: 拡張子｝
# ここに無い形式は、アップロードさせない（想定内のファイルを防ぐ）

IMAGE_TYPES = {"image/jpeg": ".jpg","image/png": ".png"}
VIDEO_TYPES = {"video/mp4": ".mp4"}

MAX_IMAGES = 20     #画像は1作品につき20枚まで
EXPIRES_IN = 120    #書名付きurlの有効期限（秒）　120秒＝2分

@csrf_exempt      #アプリ（flutter）からのPOSTを受けるため、CSRFチェックを外す
@require_POST     #POST以外（GETなど）で来たら、405エラーで断る
def uploadUrlView(request):

    # 手順１　　ログイン確認（誰がアップロードしようとしているのか）
    # ------------------------------------------------------------
    # Flutter は「Authorization: Bearer <IDトークン>」というヘッダーを付けて送ってくる。
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

    # ------------------------------------------------------------
    # 手順2: 送られてきた内容を読み取る
    # ------------------------------------------------------------
    # 期待する形: {"work_type": 2, "content_types": ["image/png", "image/jpeg"]}

    try:
        body = json.loads(request.body or "{}")          # 本文(JSON)を辞書に変換
    except json.JSONDecodeError:
        # print("jisyo error")
        return JsonResponse({"error": "invalid_json"}, status=400)
                                                                                         
    work_type = body.get("work_type")           # 2=画像, 3=動画  
    content_types = body.get("content_types")     # ファイルごとの形式のリスト
    # print(work_type)
    print(content_types)
    # content_types が「中身のあるリスト」でなければ、不正な入力。
    if not isinstance(content_types, list) or not content_types:
        # print("zissou error")
        return JsonResponse({"error": "invalid_content_types"}, status=400)


        # ------------------------------------------------------------
    # 手順3: 作品の種類ごとに、許可する形式と枚数を決める
    # ------------------------------------------------------------
    if work_type == 2:                               #画像
        allowed, max_count = IMAGE_TYPES, MAX_IMAGES
    elif work_type == 3:                             #動画
        allowed, max_count = VIDEO_TYPES, 1          #動画は1本だけ
    else:
        # 1(文字)や、その他の値は、ここでは受け付けない。
        return JsonResponse({"error":"invalid_work_type"}, status=400)

    if len(content_types) > max_count:
        # 枚数オーバー(画像なら21枚目以降)

        return JsonResponse({"error":"too_many_files"}, status=400)
    if any(ct not in allowed for ct in content_types):
        # 許可していない形式が1つでも混ざっている

        return JsonResponse({"error":"unsupported_content_type"}, status=400)

        # ------------------------------------------------------------
    # 手順4: ファイルごとに、署名付きURLを作る
    # ------------------------------------------------------------

    s3 = s3_client()
    uploads =[]
    for ct in content_types:
        # S3上の保存場所(key)を、サーバー側で決める。
        #   works/<ユーザーのpk>/<ランダムな名前>.<拡張子>
        # ・ユーザーごとにフォルダを分けておくと、③で「自分のファイルか」を確認できる。
        # ・名前をランダムにして、他のファイルを上書きしないようにする。
        # ・ファイル名をクライアントに決めさせない(細工を防ぐため)。

        key = f"works/{user.pk}/{uuid.uuid4().hex}{allowed[ct]}"

        # 署名付きURLを作る。
        #   "put_object" : このURLで「アップロード(PUT)」だけを許可する、という意味
        #   Bucket / Key : どのバケットの、どの場所か
        #   ContentType  : この形式のファイルだけ許可(送るときも同じ値を付ける必要がある)
        #   ExpiresIn    : 有効時間(秒)。過ぎるとそのURLは使えなくなる
        url = s3.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": bucket_name("works"),
                "Key": key,
                # "ContentType": ct,
            },
            ExpiresIn=EXPIRES_IN,
        )
        uploads.append({"upload_url": url, "key": key, "content_type": ct})

    # ------------------------------------------------------------
    # 手順5: 結果を返す
    # ------------------------------------------------------------
    # Flutter は、upload_url に、ファイルを送り(②)、
    # 送り終わったら、key を ③ の view に渡す。
    print("uploadurl dekita")
    return JsonResponse({"uploads": uploads, "expires_in": EXPIRES_IN})