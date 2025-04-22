import json
import base64
import urllib.request
import os
from shared.secrets import get_secret

ZENDESK_SUBDOMAIN = os.environ['ZENDESK_SUBDOMAIN']
ZENDESK_ADMIN_EMAIL = os.environ['ZENDESK_ADMIN_EMAIL']

def update_zendesk_ticket(ticket_id: str, comment: str, solve: bool = False):
    zendesk_token = get_secret("zendesk_api_key")
    url = f"https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json"
    
    auth_string = f"{ZENDESK_ADMIN_EMAIL}/token:{zendesk_token}"
    auth_encoded = base64.b64encode(auth_string.encode()).decode()

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {auth_encoded}"
    }

    data = {
        "ticket": {
            **({"status": "solved"} if solve else {}),
            "comment": {
                "body": comment
            }
        }
    }

    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers, method="PUT")
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())
