# import jwt
# import datetime
#
# # Load private key
# with open("D:/python projects/python/django projects/freelance/APS/backend/secret/private.pem", "r") as key_file:
#     private_key = key_file.read()
#
# # Use timezone-aware datetime
# now = datetime.datetime.now(datetime.UTC)
#
# # Set expiration time (Increase if needed)
# EXPIRY_HOURS = 200  # Change this to 2 or more hours if your token expires too soon
#
# # Define payload
# payload = {
#     "sub": "aps-express",
#     "iat": int(now.timestamp()),
#     "exp": int((now + datetime.timedelta(hours=EXPIRY_HOURS)).timestamp()),  # Increased expiry time
#     "iss": "aps-express",
#     "aud": "https://pushservice.egov.uz"
# }
#
# # Generate JWT token with RSASHA512
# token = jwt.encode(payload, private_key, algorithm="RS512")
#
# print("Generated JWT Token:")
# print(token)
#
# # Load public key
# with open("D:/python projects/python/django projects/freelance/APS/backend/secret/public.pem", "r") as key_file:
#     public_key = key_file.read()
#
# # Decode and verify the JWT
# try:
#     decoded_payload = jwt.decode(token, public_key, algorithms=["RS512"], audience="https://pushservice.egov.uz")
#     print("\nDecoded JWT Payload:")
#     print(decoded_payload)
# except jwt.ExpiredSignatureError:
#     print("Error: Token has expired! Consider increasing the expiration time.")
# except jwt.InvalidTokenError:
#     print("Error: Invalid token!")


import requests

token = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjM3Nzk4OSwiZXhwIjoxNzQzMDk3OTg5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.UxfpE1Cbi2c3rzNpfKE_5Sua8JzQMtE5HSVFMAtfPgEqEoHEheJXiu5KC0XGhreN7ViJKs3JCptQPHUItHUdWzcaOl6aLcrWSlGXxkql3f2LwKeMxfi6rEPJC09iuAcRCZh17l8SCfWLw07zAe3OEvTupeLCKtXTlYHOqu0Z8NPtpTchAoBQWK8lauWnBadozfAC6n4-FK7008rxQHzZz-6MLGPo9npa0luM55wM9TNI6TwwVPiqjtjxs8GoH3CMPhwEgxP4g4JOLrMK2RXf7YkpoZLvGZMfXsOgbzmYdRzopDT1xntS8B8bVONTMWiX-Rm1QQ7vCPBJ4uKZ1W70Gg"
url = "https://pushservice.egov.uz/v3/app/mq/ping"
headers = {"Authorization": f"Bearer {token}"}

response = requests.get(url, headers=headers)
print(response.status_code, response.text)


import requests
import uuid
import json
from datetime import datetime

url = "https://pushservice.egov.uz/v3/app/mq/receive"

headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjM3Nzk4OSwiZXhwIjoxNzQzMDk3OTg5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.UxfpE1Cbi2c3rzNpfKE_5Sua8JzQMtE5HSVFMAtfPgEqEoHEheJXiu5KC0XGhreN7ViJKs3JCptQPHUItHUdWzcaOl6aLcrWSlGXxkql3f2LwKeMxfi6rEPJC09iuAcRCZh17l8SCfWLw07zAe3OEvTupeLCKtXTlYHOqu0Z8NPtpTchAoBQWK8lauWnBadozfAC6n4-FK7008rxQHzZz-6MLGPo9npa0luM55wM9TNI6TwwVPiqjtjxs8GoH3CMPhwEgxP4g4JOLrMK2RXf7YkpoZLvGZMfXsOgbzmYdRzopDT1xntS8B8bVONTMWiX-Rm1QQ7vCPBJ4uKZ1W70Gg"
}

data = {
    "correlationId": str(uuid.uuid4()),  # Generate a unique ID
    "data": {"message": "Sample data"},  # Replace with actual data (≤50KB)
}

response = requests.post(url, headers=headers, json=data)

print(response.status_code, response.text)




url = "https://pushservice.egov.uz/v3/app/mq/publisher/fetch-subscribers"

headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjM3Nzk4OSwiZXhwIjoxNzQzMDk3OTg5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.UxfpE1Cbi2c3rzNpfKE_5Sua8JzQMtE5HSVFMAtfPgEqEoHEheJXiu5KC0XGhreN7ViJKs3JCptQPHUItHUdWzcaOl6aLcrWSlGXxkql3f2LwKeMxfi6rEPJC09iuAcRCZh17l8SCfWLw07zAe3OEvTupeLCKtXTlYHOqu0Z8NPtpTchAoBQWK8lauWnBadozfAC6n4-FK7008rxQHzZz-6MLGPo9npa0luM55wM9TNI6TwwVPiqjtjxs8GoH3CMPhwEgxP4g4JOLrMK2RXf7YkpoZLvGZMfXsOgbzmYdRzopDT1xntS8B8bVONTMWiX-Rm1QQ7vCPBJ4uKZ1W70Gg"  # Add your token here
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    subscribers = response.json()
    print("Subscribers List:")
    for sub in subscribers:
        print(sub)
        print(f"Company: {sub['companyName']}, System: {sub['systemName']}, Status: {sub['status']}")
else:
    print(f"Error {response.status_code}: {response.text}")





import requests

url = "https://pushservice.egov.uz/v3/app/mq/publisher/fetch-daily-delivery-statistics"

headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjM3Nzk4OSwiZXhwIjoxNzQzMDk3OTg5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.UxfpE1Cbi2c3rzNpfKE_5Sua8JzQMtE5HSVFMAtfPgEqEoHEheJXiu5KC0XGhreN7ViJKs3JCptQPHUItHUdWzcaOl6aLcrWSlGXxkql3f2LwKeMxfi6rEPJC09iuAcRCZh17l8SCfWLw07zAe3OEvTupeLCKtXTlYHOqu0Z8NPtpTchAoBQWK8lauWnBadozfAC6n4-FK7008rxQHzZz-6MLGPo9npa0luM55wM9TNI6TwwVPiqjtjxs8GoH3CMPhwEgxP4g4JOLrMK2RXf7YkpoZLvGZMfXsOgbzmYdRzopDT1xntS8B8bVONTMWiX-Rm1QQ7vCPBJ4uKZ1W70Gg"  # Add your token here
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    stats = response.json()
    print("Daily Delivery Statistics:")
    for stat in stats:
        print(f"Date: {stat['date']}, Total Subscribers: {stat['totalSubscribers']}")
        print(f"Processed Messages: {stat['processedMessages']}, Successful: {stat['successfulDeliveries']}")
        print(f"Failed: {stat['failedDeliveries']}, Pending: {stat['pendingDeliveries']}\n")
else:
    print(f"Error {response.status_code}: {response.text}")



import requests

uuid = "34e5c5a3-983e-4909-ab19-9360dce23460"  # Replace with actual UUID
url = f"https://pushservice.egov.uz/v3/app/mq/publisher/fetch-delivery-detailed-report/{uuid}"

headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjM3Nzk4OSwiZXhwIjoxNzQzMDk3OTg5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.UxfpE1Cbi2c3rzNpfKE_5Sua8JzQMtE5HSVFMAtfPgEqEoHEheJXiu5KC0XGhreN7ViJKs3JCptQPHUItHUdWzcaOl6aLcrWSlGXxkql3f2LwKeMxfi6rEPJC09iuAcRCZh17l8SCfWLw07zAe3OEvTupeLCKtXTlYHOqu0Z8NPtpTchAoBQWK8lauWnBadozfAC6n4-FK7008rxQHzZz-6MLGPo9npa0luM55wM9TNI6TwwVPiqjtjxs8GoH3CMPhwEgxP4g4JOLrMK2RXf7YkpoZLvGZMfXsOgbzmYdRzopDT1xntS8B8bVONTMWiX-Rm1QQ7vCPBJ4uKZ1W70Gg"  # Add your token here
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    report = response.json()
    print(f"Delivery Report for: {report['correlationId']}")
    print(f"Processed At: {report['processedDateTime']}\n")

    for delivery in report["deliveries"]:
        print(f"Status: {delivery['status']}")
        for info in delivery["info"]:
            print(f" - Subscriber: {info['subscriberSystem']}")
            print(f" - Calculated ID: {info.get('calculatedId', 'N/A')}")
            print(f" - Last Try: {info['lastTryDateTime']}\n")
else:
    print(f"Error {response.status_code}: {response.text}")
