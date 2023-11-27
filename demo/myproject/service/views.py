import random
import time

from django.http import JsonResponse
from django.shortcuts import render
from django.utils.timezone import now


def random_number(request):
    number = random.randint(1, 100)
    return JsonResponse({"number": number})


def clock(request):
    current_time = now()
    return render(
        request,
        "service/dashboard.html",
        {"current_time": current_time},
    )


def service_status(request):
    try:
        # Simulate some processing time
        time.sleep(random.uniform(0.1, 1.0))
        response_time = round(
            random.uniform(0.1, 1.0), 2
        )  # Simulated response time in seconds
        return JsonResponse(
            {
                "status": "Operational",
                "response_time": response_time,
                "last_checked": now().strftime("%Y-%m-%d %H:%M:%S"),
            }
        )
    except Exception as e:
        return JsonResponse(
            {
                "status": "Down",
                "error": str(e),
                "last_checked": now().strftime("%Y-%m-%d %H:%M:%S"),
            }
        )
