from firebase_admin import messaging

def send_push_notification(token, title, body, data=None):
    """
    Send a push notification to a specific device using Firebase Cloud Messaging (FCM).
    :param token: The device FCM token.
    :param title: Notification title.
    :param body: Notification body.
    :param data: Additional data (optional).
    """
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=token,
        data=data if data else {}
    )

    try:
        response = messaging.send(message)
        print(f"Notification sent successfully: {response}")
        return response
    except Exception as e:
        print(f"Error sending notification: {e}")
        return None
