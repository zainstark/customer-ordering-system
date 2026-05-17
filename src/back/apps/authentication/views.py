import uuid
from django.utils import timezone
from django.contrib.auth.hashers import make_password, check_password
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.exceptions import AuthenticationFailed
from rest_framework import status
from rest_framework_simplejwt.tokens import AccessToken
from .models import Accounts
from .serializers import RegisterSerializer, LoginSerializer
from django.core.cache import cache
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

def get_tokens(account):
    access = AccessToken()
    access['account_id'] = account.account_id
    access['email'] = account.email
    access['role'] = account.role
    access['display_name'] = account.display_name
    return {
        'access': str(access),
    }

MAX_FAILED_ATTEMPTS = 5
LOCKOUT_MINUTES = 15
ATTEMPT_WINDOW_MINUTES = 10


def _attempt_key(email):
    return f"auth_attempts:{email.lower()}"


def _lock_key(email):
    return f"auth_lock:{email.lower()}"



class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        now = timezone.now()
        account = Accounts(
            account_id=str(uuid.uuid4()),
            display_name=serializer.validated_data['display_name'],
            email=serializer.validated_data['email'],
            password_hash=make_password(serializer.validated_data['password']),
            phone_number=serializer.validated_data.get('phone_number', ''),
            role='customer',
            active=True,
            created_at=now,
            updated_at=now,
        )
        account.save()
        return Response(get_tokens(account), status=status.HTTP_201_CREATED)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
    
        email = serializer.validated_data['email'].lower()
        password = serializer.validated_data['password']
    
        # --------------------------------------------------
        # Check lockout
        # --------------------------------------------------
        lock_until = cache.get(_lock_key(email))
    
        if lock_until:
            remaining_seconds = int(
                (lock_until - timezone.now()).total_seconds()
            )
    
            if remaining_seconds > 0:
                raise AuthenticationFailed(
                    'Account temporarily locked. Try again later or reset your password.'
                )
            else:
                cache.delete(_lock_key(email))
    
        # --------------------------------------------------
        # Find account
        # --------------------------------------------------
        try:
            account = Accounts.objects.get(email=email)
        except Accounts.DoesNotExist:
            raise AuthenticationFailed('Invalid email or password')
    
        if not account.active:
            raise AuthenticationFailed('Account is disabled')
    
        # --------------------------------------------------
        # Password check
        # --------------------------------------------------
        if not check_password(password, account.password_hash):
    
            attempt_data = cache.get(_attempt_key(email))
    
            now = timezone.now()
    
            if not attempt_data:
                attempt_data = {
                    "count": 1,
                    "first_attempt": now.isoformat(),
                }
            else:
                first_attempt = timezone.datetime.fromisoformat(
                    attempt_data["first_attempt"]
                )
    
                # Reset if outside 10 minute window
                if now - first_attempt > timedelta(
                    minutes=ATTEMPT_WINDOW_MINUTES
                ):
                    attempt_data = {
                        "count": 1,
                        "first_attempt": now.isoformat(),
                    }
                else:
                    attempt_data["count"] += 1
    
            # Save attempt data for 10 mins
            cache.set(
                _attempt_key(email),
                attempt_data,
                timeout=ATTEMPT_WINDOW_MINUTES * 60,
            )
    
            # Lock account
            if attempt_data["count"] >= MAX_FAILED_ATTEMPTS:
                lock_until = now + timedelta(
                    minutes=LOCKOUT_MINUTES
                )
    
                cache.set(
                    _lock_key(email),
                    lock_until,
                    timeout=LOCKOUT_MINUTES * 60,
                )
    
                logger.warning(
                    "Account locked: email=%s ip=%s time=%s",
                    email,
                    request.META.get("REMOTE_ADDR"),
                    now.isoformat(),
                )
    
                cache.delete(_attempt_key(email))
    
                raise AuthenticationFailed(
                    'Account temporarily locked. Try again later or reset your password.'
                )
    
            raise AuthenticationFailed(
                'Invalid email or password'
            )
    
        # --------------------------------------------------
        # Successful login
        # --------------------------------------------------
        cache.delete(_attempt_key(email))
        cache.delete(_lock_key(email))
    
        return Response(get_tokens(account))

