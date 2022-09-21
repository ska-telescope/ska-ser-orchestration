-include .make/base.mk
-include .make/python.mk
-include PrivateRules.mak

PYTHON_LINT_TARGET=scripts
TF_LINT_TARGET?=

TF_ROOT_DIR?=.
TF_TARGET?=
TF_AUTO_APPROVE?=

TF_ARGUMENTS?=

TF_INVENTORY_DIR?= $(TF_ROOT_DIR)/inventory

ifeq ($(TF_LINT_TARGET),)
    TF_LINT_TARGET := $(shell find . -name 'terraform.tf' | sed 's/.terraform.tf//' | sort | uniq )
endif

ifneq ($(TF_TARGET),)
    TF_ARGUMENTS := $(TF_ARGUMENTS) -target=$(TF_TARGET)
endif

ifeq ($(TF_AUTO_APPROVE),true)
    TF_ARGUMENTS := $(TF_ARGUMENTS) -auto-approve
endif

# Ansible inventory is generated on the corresponding installation folder
ifdef PLAYBOOKS_ROOT_DIR
TF_INVENTORY_DIR="$(PLAYBOOKS_ROOT_DIR)"
endif

# TODO: Create terraform support in makefile and gitlab templates
tf-lint:
	@mkdir -p build/reports; \
	rm -rf build/reports/tflint-*.xml; \
	for TF_TARGET in $(TF_LINT_TARGET); do \
		TF_MODULE=$$(basename $$TF_TARGET) ; \
		echo "# Linting module at '$$TF_MODULE'" ; \
		tflint $$TF_TARGET -f junit > build/reports/tflint-$$TF_MODULE.xml ; \
		TF_LINT_RESULT=$$?; \
		TF_LINT_FAILURES=$$(cat build/reports/tflint-$$TF_MODULE.xml | grep -Eo 'failures="[0-9]+"' | sed 's/[^0-9]*//g' | awk '{s+=$$1} END {print s}') ; \
		[ $$TF_LINT_RESULT -ne 0 ] && \
		(echo "** Failed with code '$$TF_LINT_RESULT' and with $$TF_LINT_FAILURES failures. Check build/reports/$$TF_MODULE.xml") || \
		echo "** All good !"; \
	done; \
	TF_LINT_TOTAL_FAILURES=$$(cat build/reports/tflint-*.xml | grep -Eo 'failures="[0-9]+"' | sed 's/[^0-9]*//g' | awk '{s+=$$1} END {print s}') ; \
	if [ $$TF_LINT_TOTAL_FAILURES -ne 0 ]; then \
		printf "\n* Failed with a total of $$TF_LINT_TOTAL_FAILURES failures\n"; \
		exit 1; \
	else \
		printf "\n* All good !\n"; \
		exit 0; \
	fi; \


lint: tf-lint
	@echo "Linting Python Code"
	@make python-lint

format:
	@echo "Formatting Terraform Code"
	@terraform fmt -recursive .
	@echo "Formatting Python Code"
	@make python-format

init:
	@terraform -chdir=$(TF_ROOT_DIR) init --upgrade

apply:
	@terraform -chdir=$(TF_ROOT_DIR) apply $(TF_ARGUMENTS)

plan:
	@terraform -chdir=$(TF_ROOT_DIR) plan $(TF_ARGUMENTS)

destroy:
	@terraform -chdir=$(TF_ROOT_DIR) destroy $(TF_ARGUMENTS)

refresh:
	@terraform -chdir=$(TF_ROOT_DIR) refresh $(TF_ARGUMENTS)

generate-inventory:
	@sh -c "scripts/tfstate_to_ansible_inventory.py -o $(TF_INVENTORY_DIR)"
