-include .make/base.mk
-include .make/python.mk
-include PrivateRules.mak

PYTHON_LINT_TARGET=scripts
TERRAFORM_LINT_TARGET?=

ifeq ($(TERRAFORM_LINT_TARGET),)
    TERRAFORM_LINT_TARGET := $(shell find . -name 'terraform.tf' | sed 's#.terraform.tf##' | sort | uniq)
endif

# TODO: Create terraform support in makefile and gitlab templates
tflint:
	@mkdir -p build/reports; \
	rm -rf build/reports/tflint-*.xml; \
	for TARGET in $(TERRAFORM_LINT_TARGET); do \
		MODULE=$$(basename $$TARGET) ; \
		echo "# Linting module at '$$MODULE'" ; \
		tflint $$TARGET -f junit > build/reports/tflint-$$MODULE.xml ; \
		LINT_RESULT=$$?; \
		LINT_FAILURES=$$(cat build/reports/tflint-$$MODULE.xml | grep -Eo 'failures="[0-9]+"' | sed 's/[^0-9]*//g' | awk '{s+=$$1} END {print s}') ; \
		[ $$LINT_RESULT -ne 0 ] && \
		(echo "** Failed with code '$$LINT_RESULT' and with $$LINT_FAILURES failures. Check build/reports/$$MODULE.xml") || \
		echo "** All good !"; \
	done; \
	TOTAL_FAILURES=$$(cat build/reports/tflint-*.xml | grep -Eo 'failures="[0-9]+"' | sed 's/[^0-9]*//g' | awk '{s+=$$1} END {print s}') ; \
	if [ $$TOTAL_FAILURES -ne 0 ]; then \
		printf "\n* Failed with a total of $$TOTAL_FAILURES failures\n"; \
		exit 1; \
	else \
		printf "\n* All good !\n"; \
		exit 0; \
	fi; \


lint: tflint
	@echo "Linting Python Code"
	@make python-lint

format:
	@echo "Formatting Terraform Code"
	@terraform fmt -recursive .
	@echo "Formatting Python Code"
	@make python-format
