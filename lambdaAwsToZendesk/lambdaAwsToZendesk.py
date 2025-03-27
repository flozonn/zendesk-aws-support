import json
import urllib.request
import base64
import logging
import boto3
import os


S3 = boto3.client('s3')

SUPPORT = boto3.client('support')
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
ZENDESK_TOKEN = os.environ['ZENDESK_TOKEN']
ZENDESK_SUBDOMAIN = os.environ['ZENDESK_SUBDOMAIN']
ZENDESK_ADMIN_EMAIL = os.environ['ZENDESK_ADMIN_EMAIL']

def update_zendesk_ticket(ticket_id, comment, solve=False):

    url = f"https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json"
    auth_string = f"{ZENDESK_ADMIN_EMAIL}/token:{ZENDESK_TOKEN}"
    auth_encoded = base64.b64encode(auth_string.encode()).decode()
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Basic {auth_encoded}"
    }
    
    data = {
        "ticket": {
            **({"status": "solved"} if solve else {}),
            "comment": {
                "body": comment,
            }
        }
    }
    
    req = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers, method="PUT")
    
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        raise Exception(f"Erreur lors de la mise à jour du ticket: {e}")



def get_s3_object( key):
    try:
        response = S3.get_object(Bucket=os.environ['S3_BUCKET_NAME'], Key=key)
        content = response["Body"].read().decode("utf-8") 
        return content
    except Exception as e:
        print("❌ Error when retrieving data from S3:", str(e))
        return None

def lambda_handler(event, context):
    """
    AWS Lambda function that logs support case events from EventBridge.
    """
    try:
        LOGGER.info("Received AWS Support Case Event:")
        LOGGER.info(json.dumps(event, indent=2))
        event_name = event.get('detail', {}).get('event-name', 'Unknown')
        event_origin = event.get('detail', {}).get('origin', 'Unknown')
        case_id = event.get('detail', {}).get('case-id', 'Unknown')

        print(case_id)
        print(event_name)
        print(event_origin)
        if(event_name == "AddCommunicationToCase" and event_origin == "AWS"):
            print("send comm to Zendesk API")
            z_id =  get_s3_object(case_id)
            print("retrieving the last message from support")
            response = SUPPORT.describe_communications(
                caseId=case_id,
                maxResults=10
            )
            print(response['communications'][0])
            try:
                z_response = update_zendesk_ticket(
                    ticket_id=z_id,
                    comment=response['communications'][0]['body'],
                )
                print("✅ Ticket mis à jour avec succès!")

            except Exception as e:
                print(f"❌ Erreur: {e}")

        if(event_name == "ResolveCase"):
            z_id =  get_s3_object(case_id)
            z_response = update_zendesk_ticket(
                    ticket_id=z_id,
                    comment='solved',
                    solve=True
                )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Support case event logged successfully"})
        }

    except Exception as e:
        LOGGER.error(f"Error processing support case event: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error processing event", "error": str(e)})
        }
