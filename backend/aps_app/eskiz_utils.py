import requests

ESKIZ_EMAIL = 'apsexpressuzb@gmail.com'
ESKIZ_PASSWORD = 'YlwQz8O0xu8lt6wJ2NyXv7fOllUDmov3PuTTjteW'

def get_token():
    url = 'https://notify.eskiz.uz/api/auth/login'
    data = {'email': ESKIZ_EMAIL, 'password': ESKIZ_PASSWORD}
    response = requests.post(url, data=data)
    return response.json()['data']['token']


def send_sms(phone_number, message):
    token = get_token()
    url = 'https://notify.eskiz.uz/api/message/sms/send'
    headers = {'Authorization': f'Bearer {token}'}
    data = {
        'mobile_phone': phone_number,
        'message': message,
        'from': '4546'
    }
    response = requests.post(url, headers=headers, data=data)
    return response.json()