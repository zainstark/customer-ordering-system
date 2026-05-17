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

def get_tokens(account):
    access = AccessToken()
    access['account_id'] = account.account_id
    access['email'] = account.email
    access['role'] = account.role
    access['display_name'] = account.display_name
    return {
        'access': str(access),
    }

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
        try:
            account = Accounts.objects.get(email=serializer.validated_data['email'])
        except Accounts.DoesNotExist:
            raise AuthenticationFailed('Invalid credentials')
        if not account.active:
            raise AuthenticationFailed('Account is disabled')
        if not check_password(serializer.validated_data['password'], account.password_hash):
            raise AuthenticationFailed('Invalid credentials')
        return Response(get_tokens(account))

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return Response(status=status.HTTP_205_RESET_CONTENT)
