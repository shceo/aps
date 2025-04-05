# import jwt
# import datetime
# from django.conf import settings
# from pathlib import Path
#
# # Define paths to private and public key files
# PRIVATE_KEY_PATH = Path(settings.BASE_DIR) / "secret/private.pem"
# PUBLIC_KEY_PATH = Path(settings.BASE_DIR) / "secret/public.pem"
#
# # Load private key
# def load_private_key():
#     with open(PRIVATE_KEY_PATH, "r") as key_file:
#         return key_file.read()
#
# # Load public key
# def load_public_key():
#     with open(PUBLIC_KEY_PATH, "r") as key_file:
#         return key_file.read()
#
# def generate_jwt():
#     """Generate a JWT token for authentication."""
#     now = datetime.datetime.now(datetime.UTC)
#
#     payload = {
#         "sub": "aps-express",
#         "iat": int(now.timestamp()),
#         "exp": int((now + datetime.timedelta(hours=1)).timestamp()),  # Token expires in 1 hour
#         "iss": "aps-express",
#         "aud": "https://pushservice.egov.uz"
#     }
#
#     private_key = load_private_key()
#     token = jwt.encode(payload, private_key, algorithm="RS512")
#     return token
#
# def decode_jwt(token):
#     """Decode and verify a JWT token."""
#     try:
#         public_key = load_public_key()
#         decoded = jwt.decode(token, public_key, algorithms=["RS512"], audience="https://pushservice.egov.uz")
#         return decoded
#     except jwt.ExpiredSignatureError:
#         return {"error": "Token has expired"}
#     except jwt.InvalidTokenError:
#         return {"error": "Invalid token"}
