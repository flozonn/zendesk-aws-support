
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
BEARER_TOKEN          = os.environ['BEARER_TOKEN']

def verify_signature(bearer):
    return bearer == BEARER_TOKEN



def lambda_handler(event, context):
    print("hello")
    print(event)

    bearer = event['headers'].get('authorization', '')

    try:
        return {
            "isAuthorized": verify_signature(bearer)
        }
    except Exception as e:
        LOGGER.exception('Error handling webhook')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error handling signature', 'error': str(e)}),
}