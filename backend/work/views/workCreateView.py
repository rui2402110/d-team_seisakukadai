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

