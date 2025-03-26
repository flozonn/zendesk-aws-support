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
	rm -f $(ZIP_FILES)
	terraform destroy -auto-approve

