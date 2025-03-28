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


# UP is the part to get the JWT token that expires in 200 hours.


import requests

token = 'eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MzE0OTkxOSwiZXhwIjoxNzQzODY5OTE5LCJpc3MiOiJhcHMtZXhwcmVzcyIsImF1ZCI6Imh0dHBzOi8vcHVzaHNlcnZpY2UuZWdvdi51eiJ9.q97BetVzk-wXEzch6Cti67gh6VJ-5SCdJUqP__PuvV0IpY8yuqu8-mQ8LYwLlGZBpbwNW8lNjf-Mx7nHw0n7seXn5LlHoyfXqipCPG9Yspr1Y0zNFKkRlNzpw2ki4iK7iXB0Hb_Ybz4e483HZXMXVuKogrNr-vHY5SPeIoQdfZRatOfgcPI-Uxzr8iGmPz-hsOPwuJFXgud6RYcB9avKds_APDROU4jLR6KH-dCyy918Uy9-itvD1niWX6NjsVAuFn-SjNX3rF3LHcCz1cb0l_TbJf31cD4HVJjt0MCTjhPs1jpdTP5BvfA7z6x_gsAFvsJG6-j24BRl0mK0zu9o8w'
url = "https://pushservice.egov.uz/v3/app/mq/ping"
headers = {"Authorization": f"Bearer {token}"}

response = requests.get(url, headers=headers)
print(response.status_code, response.text)



# For part 5.2.1  and 5.2.2 of the documentation

import requests
import uuid
import json
from datetime import datetime

url = "https://pushservice.egov.uz/v3/app/mq/receive"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {token}"
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
    "Authorization": f"Bearer {token}"
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
    "Authorization": f"Bearer {token}"
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
    "Authorization": f"Bearer {token}"
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


