.PHONY: all zip clean deploy

ZIP_FILES = lambdaZendeskToAws.zip lambdaWebhooksToEventBridge.zip lambdaAwsToZendesk.zip

all: zip deploy

zip:
	cd lambdaZendeskToAws && rm ./lambdaZendeskToAws.zip && pip install --target ./package boto3 aws_xray_sdk && cd package && zip -r ../lambdaZendeskToAws.zip . && cd .. && zip lambdaZendeskToAws.zip lambdaZendeskToAws.py
	cd lambdaAwsToZendesk && rm ./lambdaAwsToZendesk.zip && pip install --target ./package boto3 aws_xray_sdk && cd package && zip -r ../lambdaAwsToZendesk.zip . && cd .. && zip lambdaAwsToZendesk.zip lambdaAwsToZendesk.py
	cd lambdaApiAuthorizer && rm ./lambdaApiAuthorizer.zip  && pip install --target ./package boto3 aws_xray_sdk && cd package && zip -r ../lambdaApiAuthorizer.zip . && cd .. && zip lambdaApiAuthorizer.zip lambdaApiAuthorizer.py

deploy:
	terraform fmt && cd platform && terraform apply -auto-approve

clean:
	cd platform && terraform destroy -auto-approve

codescanner:
	bandit -r lambdaAwsToZendesk -f json > codescans/lambdaAwsToZendesk.json ; \
	bandit -r lambdaApiAuthorizer -f json > codescans/lambdaApiAuthorizer.json ; \
	bandit -r lambdaZendeskToAws -f json > codescans/lambdaZendeskToAws.json ; \
	detect-secrets scan > codescans/.secrets.baseline ; \
	checkov -d platform -o json > codescans/terraform.json ; \
	semgrep --config=auto . --json > codescans/semgrep_report.json



