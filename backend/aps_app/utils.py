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
from aps_app.models import City, Region

# Define the regions and their respective tumans with 'tuman' appended
uzbekistan_regions = {
    'Xorazm': [
        "Bogʻot tuman", "Gurlan tuman", "Xonqa tuman", "Tuproqqal’a tumani",
        "Xiva tumani", "Qoʻshkoʻpir tumani", "Shovot tumani", "Urganch tumani",
        "Yangiariq tumani", "Yangibozor tumani", "Hazorasp tumani"
    ],
    'Buxoro': [
        "Olot tuman", "Buxoro tuman", "Gʻijduvon tuman", "Jondor tuman", "Kogon tuman",
        "Qorakoʻl tuman", "Qorovulbozor tuman", "Yangibozor tuman", "Romitan tuman",
        "Shofirkon tuman", "Vobkent tuman"
    ],
    'Navoi': [
        "Konimex tuman", "Karmana tuman", "Qiziltepa tuman", "Xatirchi tuman", "Navbahor tuman",
        "Nurota tuman", "Tomdi tuman", "Uchquduq tuman"
    ],
    'Qashqadaryo': [
        "Dehqonobod tuman", "Kasbi tuman", "Kitob tuman", "Koson tuman", "Koʻkdala tuman",
        "Mirishkor tuman", "Muborak tuman", "Nishon tuman", "Qamashi tuman", "Qarshi tuman",
        "Yakkabogʻ tuman", "Gʻuzor tuman", "Shahrisabz tuman", "Chiroqchi tuman"
    ],
    'Surxondaryo': [
        "Angor tuman", "Boysun tuman", "Denov tuman", "Jarqoʻrgon tuman", "Kizirik tuman",
        "Muzrobod tuman", "Oltinsoy tuman", "Sariosiyo tuman", "Shoʻrchi tuman", "Shershan tuman",
        "Termiz tuman", "Uzun tuman", "Qumqoʻrgʻon tuman", "Bandikhon tuman"
    ],
    # You can add more regions and tumans here...
}

# Insert tumans into the database
for region_name, tuman_names in uzbekistan_regions.items():
    region_obj, created = Region.objects.get_or_create(title=region_name)  # Get or create Region object
    for tuman_name in tuman_names:
        City.objects.get_or_create(title=tuman_name, region=region_obj)  # Get or create Tuman for each city
