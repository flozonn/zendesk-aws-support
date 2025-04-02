import json
import boto3
import logging
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

patch_all()
LOGGER = logging.getLogger()
LOGGER.setLevel('INFO')

SUPPORT = boto3.client('support')
DYNAMO = boto3.client('dynamodb')


def get_lookup_id(key):
    response = DYNAMO.get_item( TableName= os.environ['TABLE_NAME'], Key={'id-z':{'S':key}})
    print("GET ID LOOKUP")
    print(response)
    return response['Item']['id-a']['S']


def put_lookup_id(keyA,keyz):
    response = DYNAMO.put_item(TableName=os.environ['TABLE_NAME'],Item={'id-a':{'S':keyA},'id-z':{'S':keyz}})
    print("PUT ID LOOKUP")
    print(response)
    return 

def create_support_case(payload_dict):
    '''Create an AWS Support case from the webhook data.'''
    try:
        case_subject = "TEST CASE - Please ignore"
        case_description = payload_dict['detail'].get('zd_ticket_desc', 'No description provided')
        cat_code = payload_dict['detail'].get('zd_ticket_category_code', 'No description provided')
        service_code = payload_dict['detail'].get('zd_ticket_impacted_service', 'No description provided')
        sev_code = payload_dict['detail'].get('zd_ticket_sev_code', 'No description provided')

        # Create the case in AWS Support
        response = SUPPORT.create_case(
            subject=case_subject,
            severityCode=sev_code,
            categoryCode=cat_code, 
            communicationBody=case_description,
            serviceCode=service_code,
            issueType="customer-service"
        )
        
        LOGGER.info(f"Support case created: {response['caseId']}")
        bucket_name =  os.environ['BUCKET_AWS_ZENDESK']
        file_name = response['caseId']
        content = str(payload_dict['detail'].get('zd_ticket_id'))


        put_lookup_id(response['caseId'],content)
        put_lookup_id(content,response['caseId'])
       

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'AWS Support case created', 'caseId': response['caseId']})
        }

    except Exception as e:
        LOGGER.exception('Error creating AWS Support case')
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Failed to create AWS Support case', 'error': str(e)})
        }
    
def update_support_case(payload_dict):

    response = SUPPORT.add_communication_to_case(
        caseId=get_lookup_id((str(payload_dict['detail']['zd_ticket_id']))),
        communicationBody= payload_dict['detail']['zd_ticket_latest_public_comment'],
    )
    print(response)
    return

def solve_support_case(payload_dict):
    response = SUPPORT.resolve_case(
        caseId=get_lookup_id(str(payload_dict['detail']['zd_ticket_id']))
    )

def lambda_handler(event, context):
    try:
       print("hello")
       print(event)
       if event['detail-type'] == "create.webhook":
          create_support_case(event)
       if event['detail-type'] == "update.webhook":
           update_support_case(event)
       if event['detail-type'] == "solved.webhook":
           solve_support_case(event)

    except Exception as e:
        
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error handling webhook', 'error': str(e)}),
}