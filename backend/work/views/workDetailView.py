import json
from django.db import IntegrityError
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from work.models import Work
from core.firebase import verify_id_token
from core.storage import default_icon_url


# def workDetailView(request):
