
import json
import hashlib
import hmac
import os
import base64
import logging

import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()
LOGGER = logging.getLogger()
LOGGER.setLevel('INFO')

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



def lambda_handler(event, context):
    print("hello")
    print(event)
    signature = event['headers'].get('x-zendesk-webhook-signature', '')
    timestamp = event['headers'].get('x-zendesk-webhook-signature-timestamp', '')
    try:
        return {
            "isAuthorized": verify_signature(event['body'],signature,timestamp)
        }
    except Exception as e:
        LOGGER.exception('Error handling webhook')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error handling signature', 'error': str(e)}),
}