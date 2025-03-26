.PHONY: all zip clean deploy

ZIP_FILES = lambdaZendeskToAws.zip lambdaWebhooksToEventBridge.zip lambdaAwsToZendesk.zip

all: zip deploy

zip:
	zip -r lambdaZendeskToAws.zip lambdaZendeskToAws
	zip -r lambdaWebhooksToEventBridge.zip lambdaWebhooksToEventBridge
	zip -r lambdaAwsToZendesk.zip lambdaAwsToZendesk

deploy:
	cd platform && terraform apply -auto-approve

clean:
	cd platform && terraform destroy -auto-approve

codescanner:
	bandit -r lambdaAwsToZendesk -f json > codescans/lambdaAwsToZendesk.json ; \
	bandit -r lambdaWebhooksToEventBridge -f json > codescans/lambdaWebhooksToEventBridge.json ; \
	bandit -r lambdaZendeskToAws -f json > codescans/lambdaZendeskToAws.json ; \
	detect-secrets scan > codescans/.secrets.baseline ; \
	checkov -d platform -o json > codescans/terraform.json ; \
	semgrep --config=auto . --json > codescans/semgrep_report.json



