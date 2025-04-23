.PHONY: all zip deploy clean codescanner

LAMBDA_NAMES = zendesk_to_aws aws_to_zendesk api_authorizer
LAMBDA_SRC = lambdas
SHARED_SRC = lambdas/shared
ZIP_DIR = dist
BUILD_DIR = build
PLATFORM_DIR = platform
PYTHON_DEPS = boto3 aws_xray_sdk

all: zip deploy

zip: clean_dist $(LAMBDA_NAMES)

$(LAMBDA_NAMES):
	@echo "📦 Building lambda: $@"
	rm -rf $(BUILD_DIR)/$@
	mkdir -p $(BUILD_DIR)/$@/python

	# Install Python dependencies
	pip3 install --quiet --target $(BUILD_DIR)/$@/python $(PYTHON_DEPS)

	# Copy source
	cp $(LAMBDA_SRC)/$@/handler.py $(BUILD_DIR)/$@/
	cp -r $(SHARED_SRC) $(BUILD_DIR)/$@/shared

	# Create ZIP
	cd $(BUILD_DIR)/$@ && zip -qr ../../$(ZIP_DIR)/$@.zip .
	@echo "✅ Packaged: $(ZIP_DIR)/$@.zip"

clean_dist:
	rm -rf $(ZIP_DIR)/*
	mkdir -p $(ZIP_DIR)

deploy:
	@echo "🚀 Deploying with Terraform..."
	cd $(PLATFORM_DIR) && terraform fmt && terraform apply -auto-approve
	@echo "✅ Deployment complete."

clean:
	@echo "🧹 Cleaning build and dist folders"
	rm -rf $(BUILD_DIR) $(ZIP_DIR)

codescanner:
	@echo "🔍 Running security scans..."
	mkdir -p codescans
	@for name in $(LAMBDA_NAMES); do \
		bandit -r $(LAMBDA_SRC)/$$name -f json > codescans/bandit-$$name.json; \
	done
	detect-secrets scan > codescans/.secrets.baseline
	semgrep --config=auto . --sarif > codescans/semgrep_report.sarif
	@echo " Checkov..."
	checkov --skip-framework secrets -d $(PLATFORM_DIR) -o sarif --output-file-path codescans/ 
	@echo "✅ Security scans complete."

