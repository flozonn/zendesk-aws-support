
import json
import hashlib
import hmac
import os
import base64
import logging

import boto3

LOGGER = logging.getLogger()
LOGGER.setLevel('INFO')

EVENTBRIDGE = boto3.client('events')

# Set these values in your Lambda function environment variables.
EVENT_BUS_ARN = os.environ['EVENT_BUS_ARN']
WEBHOOK_SECRET_CREATE = os.environ['WEBHOOK_SECRET_CREATE'].encode('utf-8')
WEBHOOK_SECRET_UPDATE = os.environ['WEBHOOK_SECRET_UPDATE'].encode('utf-8')
WEBHOOK_SECRET_SOLVED = os.environ['WEBHOOK_SECRET_SOLVED'].encode('utf-8')


def verify_signature(payload, signature, timestamp):
    '''Verify the provided webhook signature was created by Zendesk's Webhook feature.'''
    combined = timestamp + payload
    combined_bytes = combined.encode('utf-8')
    
    computed_hmac_create = hmac.new(WEBHOOK_SECRET_CREATE, combined_bytes, hashlib.sha256)
    computed_signature_create = base64.b64encode(computed_hmac_create.digest()).decode('utf-8')
    
    computed_hmac_update = hmac.new(WEBHOOK_SECRET_UPDATE, combined_bytes, hashlib.sha256)
    computed_signature_update = base64.b64encode(computed_hmac_update.digest()).decode('utf-8')

    computed_hmac_solved = hmac.new(WEBHOOK_SECRET_SOLVED, combined_bytes, hashlib.sha256)
    computed_signature_solved = base64.b64encode(computed_hmac_solved.digest()).decode('utf-8')

    return hmac.compare_digest(computed_signature_create, signature) or hmac.compare_digest(computed_signature_update, signature)  or hmac.compare_digest(computed_signature_solved, signature) 


def webhook_to_eventbridge(event):
    '''Forward the webhook body to AWS EventBridge.'''
    payload = event['body']
    signature = event['headers'].get('x-zendesk-webhook-signature', '')
    timestamp = event['headers'].get('x-zendesk-webhook-signature-timestamp', '')
    event_type = event["rawPath"]

    if not verify_signature(payload, signature, timestamp):
        LOGGER.warning('Received webhook with invalid signature')
        return {
            'statusCode': 403,
            'body': json.dumps({'message': 'Forbidden'}),
        }
    print("printing payload")
    print(payload)
    payload_dict = json.loads(payload) if isinstance(payload, str) else payload
    event_source = payload_dict.get('source', 'webhook.custom')
    detail_type = payload_dict.get('type', 'defaultDetailType')
    payload_dict['event_type'] = event_type

    put_events_response = EVENTBRIDGE.put_events(
        Entries=[
            {
                'Source': "zendesk.webhook",
                'DetailType': detail_type,
                'Detail': json.dumps(payload_dict),
                'EventBusName': EVENT_BUS_ARN,
            }
        ]
    )

    response_entries = put_events_response.get('Entries', [])
    if len(response_entries) == 0 or 'ErrorCode' in response_entries[0]:
        LOGGER.error(f'Push to event bridge failed: {response_entries}')
        return {
            'statusCode': 500,
            'body': json.dumps(
                {
                    'message': 'Failed to send event to EventBridge',
                    'response': put_events_response,
                }
            ),
        }

    return {
        'statusCode': 200,
        'body': json.dumps(
            {
                'message': 'Event successfully sent to EventBridge',
                'response': put_events_response,
            }
        ),
    }


def lambda_handler(event, context):
    try:
        LOGGER.info(f"Received event: {json.dumps(event, indent=2)}")
        return webhook_to_eventbridge(event)
    except Exception as e:
        LOGGER.exception('Error handling webhook')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error handling webhook', 'error': str(e)}),
}