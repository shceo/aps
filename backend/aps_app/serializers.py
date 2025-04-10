from rest_framework import serializers
from django.core.validators import RegexValidator


class RegistrationSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15)
    first_name = serializers.CharField(max_length=50)

    password = serializers.CharField(
        write_only=True,
        min_length=8,
        required=True,
        validators=[
            RegexValidator(
                regex=r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                message="Password must be at least 8 characters long, include an uppercase letter, a digit, and a special character."
            )
        ]
    )

    password_confirm = serializers.CharField(write_only=True)

    def validate_phone_number(self, value):
        if not value.startswith("+998"):
            raise serializers.ValidationError("Phone number must start with +998")
        return value

    def validate(self, data):
        if data.get("password") != data.get("password_confirm"):
            raise serializers.ValidationError({"password_confirm": "Passwords do not match."})
        return data


class OTPVerificationSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15)
    code = serializers.CharField(max_length=6)