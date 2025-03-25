import requests

# Your generated JWT token
token = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcHMtZXhwcmVzcyIsImlhdCI6MTc0MjIxNDMzMSwiZXhwIjoxNzQyMjE3OTMxfQ.KlLrAwhKO5Z_zQ618OJ7mvhFvRU0QXm3ZWYAWVfhDCYG58gE0adqC5xUvWfNVFGZ4YovKh3dq_Uzrm8WamO1zJrdTZTjYBMts5Mbqg5760wn3hhGvihfru8k8LQyFleqzq8Kue2qNKMf9DxECoQCBkoUIDtyNBITOnwe_MeJlE5Iqbz8thGQLAcGG4uHSlRlLTEpOqTvlE7yAzj65SnvzUEt_z9Jihf7qhuh8QLGlc0s4QmTIRaYhabYF7q3sQJJ7_LkAr9_gi0J5HoG1jk_Z86STtms6p1tb4I-YqK_o7cusWa-vKUcxyAK6SWLHmITtZeJsMoczJOGa4dLefOoSw"  # Replace with your actual token

# API endpoint
url = "https://pushservice.egov.uz/v3/app/mq/ping"

# Headers including the JWT token
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

# Sending the request
response = requests.post(url, headers=headers)

# Print response from the server
print("Status Code:", response.status_code)
print("Response:", response.text)
