from django.http import JsonResponse
from work.models import Work, Work_like, Work_relation, Work_image, Work_char, Work_movie
from accounts.models import User
from core.firebase import verify_id_token

def workPostView(request):
    work = Work.objects.all() 

    return JsonResponse({
     "work": list(work.values()),
})