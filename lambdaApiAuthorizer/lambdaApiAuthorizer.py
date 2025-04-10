
import json
import os
import logging

import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all
from botocore.exceptions import ClientError

patch_all()
LOGGER = logging.getLogger()
LOGGER.setLevel('INFO')

REGION_NAME  = os.environ['REGION_NAME']

def get_secret():
    secret_name = "api_key"
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

BEARER_TOKEN = get_secret()

def verify_signature(bearer):
    return bearer == BEARER_TOKEN

def lambda_handler(event, context):

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