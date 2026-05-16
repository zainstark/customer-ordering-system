from rest_framework import serializers
from .models import Accounts

class RegisterSerializer(serializers.Serializer):
    display_name = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    phone_number = serializers.CharField(required=False, allow_blank=True)

    def validate_email(self, value):
        if Accounts.objects.filter(email=value).exists():
            raise serializers.ValidationError('Email already in use')
        return value

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
