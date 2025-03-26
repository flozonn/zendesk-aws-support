import json
import boto3
import logging
import boto3
import os

LOGGER = logging.getLogger()
LOGGER.setLevel('INFO')

SUPPORT = boto3.client('support')
S3 = boto3.client('s3')

def get_s3_object( key):
    try:
        response = S3.get_object(Bucket=os.environ['BUCKET_AWS_ZENDESK'], Key=key)
        content = response["Body"].read().decode("utf-8") 
        return content
    except Exception as e:
        print("❌ Error when retrieving data from S3:", str(e))
        return None

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

        # Envoyer le fichier dans S3
        S3.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=content.encode("utf-8"), 
            ContentType="text/plain"
        )
        S3.put_object(
            Bucket=bucket_name,
            Key=content,
            Body=file_name.encode("utf-8"), 
            ContentType="text/plain"
        )

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
        caseId=get_s3_object(str(payload_dict['detail']['zd_ticket_id'])),
        communicationBody= payload_dict['detail']['zd_ticket_latest_public_comment'],
    )
    print(response)
    return

def solve_support_case(payload_dict):
    response = SUPPORT.resolve_case(
        caseId=get_s3_object(str(payload_dict['detail']['zd_ticket_id']))
    )

def lambda_handler(event, context):
    try:
       print("hello")
       print(event)
       if event['detail'].get('event_type') == "/create":
          create_support_case(event)
       if event['detail'].get('event_type') == "/update":
           update_support_case(event)
       if event['detail'].get('event_type') == "/solved":
           solve_support_case(event)

    except Exception as e:
        
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error handling webhook', 'error': str(e)}),
}