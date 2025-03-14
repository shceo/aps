import firebase_admin
from firebase_admin import credentials, messaging

# Initialize Firebase (Run this only once)
FIREBASE_CREDENTIALS_PATH = "D:/python projects/python/django projects/freelance/APS/backend/first-fce89-firebase-adminsdk-fbsvc-b4d3576d5b.json"

if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)

def send_push_notification(fcm_token, title, body):
    """
    Sends a push notification via Firebase Cloud Messaging (FCM)
    """
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            token=fcm_token,
        )
        response = messaging.send(message)
        return {"status": "success", "response": response}
    except Exception as e:
        return {"status": "error", "message": str(e)}

