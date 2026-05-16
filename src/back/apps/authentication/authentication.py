from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import AccessToken
from .models import Accounts

class CustomJWTAuthentication(BaseAuthentication):
    def authenticate(self, request):
        header = request.headers.get('Authorization', '')
        if not header.startswith('Bearer '):
            return None

        try:
            token = AccessToken(header.split(' ')[1])
            user = Accounts.objects.get(account_id=token['account_id'])
            if not user.active:
                raise AuthenticationFailed('Account is disabled')
            return (user, token)
        except Accounts.DoesNotExist:
            raise AuthenticationFailed('Account not found')
        except Exception:
            raise AuthenticationFailed('Invalid or expired token')
