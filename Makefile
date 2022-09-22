-include .make/base.mk
-include .make/python.mk
-include .make/terraform.mk
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

lint: 
	@echo "Linting Terraform Code"
	@make terraform-lint
	@echo "Linting Python Code"
	@make python-lint

format:
	@echo "Formatting Terraform Code"
	@make terraform-format
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
