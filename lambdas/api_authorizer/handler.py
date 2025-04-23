from shared.logger import get_logger
from shared.secrets import get_secret

logger = get_logger()
API_TOKEN = get_secret("api_key")

def lambda_handler(event, context):
    try:
        token = event['headers'].get('authorization', '')
        print(token)
        print(API_TOKEN)
        is_auth = token == API_TOKEN
        print(is_auth)
        return {"isAuthorized": is_auth}
    except Exception as e:
        logger.exception("Auth error")
        return None
