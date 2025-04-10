import json
import urllib.request
import base64
import logging
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all
from botocore.exceptions import ClientError

patch_all()


DYNAMO = boto3.client('dynamodb')

SUPPORT = boto3.client('support')
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
ZENDESK_SUBDOMAIN = os.environ['ZENDESK_SUBDOMAIN']
ZENDESK_ADMIN_EMAIL = os.environ['ZENDESK_ADMIN_EMAIL']
REGION_NAME         = os.environ['REGION_NAME']

def update_zendesk_ticket(ticket_id, comment,zendesk_token, solve=False):
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


def get_secret():

    secret_name = "zendesk_api_key"
    region_name = REGION_NAME

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    return secret

def get_lookup_id(key):
    response = DYNAMO.get_item( TableName= os.environ['TABLE_NAME'], Key={'id-z':{'S':key}})
    print("GET ID LOOKUP")
    print(response)
    return response['Item']['id-a']['S']

def lambda_handler(event, context):
    """
    AWS Lambda function that logs support case events from EventBridge.
    """
    try:    
        zendesk_token =  get_secret()


        LOGGER.info("Received AWS Support Case Event:")
        LOGGER.info(json.dumps(event, indent=2))
        event_name = event.get('detail', {}).get('event-name', 'Unknown')
        event_origin = event.get('detail', {}).get('origin', 'Unknown')
        case_id = event.get('detail', {}).get('case-id', 'Unknown')

        if(event_name == "AddCommunicationToCase" and event_origin == "AWS"):
            print("send comm to Zendesk API")
            z_id =  get_lookup_id(case_id)
            print("retrieving the last message from support")
            response = SUPPORT.describe_communications(
                caseId=case_id,
                maxResults=10
            )
            #print(response['communications'][0])
            try:
                update_zendesk_ticket(
                    ticket_id=z_id,
                    comment=response['communications'][0]['body'], 
                    zendesk_token=zendesk_token
                    
                )
                print("✅ Case updated")

            except Exception as e:
                print(f"❌ error: {e}")

        if(event_name == "ResolveCase"):
            z_id =  get_lookup_id(case_id)
            update_zendesk_ticket(
                    ticket_id=z_id,
                    comment='solved',
                    zendesk_token=zendesk_token,
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
