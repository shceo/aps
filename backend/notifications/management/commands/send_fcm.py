import firebase_admin
from firebase_admin import credentials, messaging
from django.core.management.base import BaseCommand

# Firebase Initialization (if not already in settings.py)
FIREBASE_CREDENTIALS_PATH = "D:/python projects/python/django projects/freelance/APS/backend/first-fce89-firebase-adminsdk-fbsvc-b4d3576d5b.json"
if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)

class Command(BaseCommand):
    help = "Send a test notification using Firebase Cloud Messaging"

    def handle(self, *args, **kwargs):
        fcm_token = "b4d3576d5b17fab2a4c941aef420d0834e0dd391"  # Replace with a valid token

        message = messaging.Message(
            notification=messaging.Notification(
                title="Hello, Zavvy!",
                body="Your Firebase setup is now working 🎉",
            ),
            token=fcm_token,
        )
        try:
            response = messaging.send(message)
        except Exception as e:
            return str(e)

        self.stdout.write(self.style.SUCCESS(f"✅ Successfully sent notification: {response}"))
