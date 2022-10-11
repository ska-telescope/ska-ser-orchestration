-include .make/base.mk
-include .make/python.mk
-include .make/terraform.mk
-include PrivateRules.mak

SHELL=/usr/bin/env bash

PYTHON_LINT_TARGET=scripts

TF_ROOT_DIR?=.
TF_INVENTORY_DIR?= $(TF_ROOT_DIR)/inventory
TF_TARGET?=
TF_AUTO_APPROVE?=
TF_ARGUMENTS?=
ENVIRONMENT?=
DATACENTER?=
GITLAB_PROJECT_ID?=

GENERATE_INVENTORY_ARGS?=

ifneq ($(TF_TARGET),)
    TF_ARGUMENTS := $(TF_ARGUMENTS) -target=$(TF_TARGET)
endif

ifeq ($(TF_AUTO_APPROVE),true)
    TF_ARGUMENTS := $(TF_ARGUMENTS) -auto-approve
endif

ifdef PLAYBOOKS_ROOT_DIR
TF_INVENTORY_DIR="$(PLAYBOOKS_ROOT_DIR)"
endif

ifneq ($(DATACENTER),)
    GENERATE_INVENTORY_ARGS := $(GENERATE_INVENTORY_ARGS) -d "$(DATACENTER)"
endif

-include PrivateRules.mak

vars:  ## Current variables
	@echo "Current variable settings:"
	@echo "ENVIRONMENT=$(ENVIRONMENT)"
	@echo "GITLAB_PROJECT_ID=$(GITLAB_PROJECT_ID)"
	@echo "TF_ROOT_DIR=$(TF_ROOT_DIR)"
	@echo "TF_INVENTORY_DIR=$(TF_INVENTORY_DIR)"
	@echo "TF_TARGET=$(TF_TARGET)"

lint: ## Lint terraform and python code
	@echo "Linting Terraform Code"
	@make terraform-lint
	@echo "Linting Python Code"
	@make python-lint

format: ## Format terraform and python code
	@echo "Formatting Terraform Code"
	@make terraform-format
	@echo "Formatting Python Code"
	@make python-format

init: ## Initiate Terraform on the local environment
	@terraform -chdir=$(TF_ROOT_DIR) init --upgrade $(TF_ARGUMENTS)

clean: ## Removes terraform module and state caches. Requires init to be executed
	@rm -rf $$(find $(TF_ROOT_DIR) -name ".terraform*" | xargs)

re-init: clean init

apply: ## Apply changes to the cluster. Filter with TF_TARGET
	@terraform -chdir=$(TF_ROOT_DIR) apply $(TF_ARGUMENTS)

plan: ## Check changes to the cluster. Filter with TF_TARGET
	@terraform -chdir=$(TF_ROOT_DIR) plan $(TF_ARGUMENTS)

destroy: ## Destroy cluster. Filter with TF_TARGET
	@terraform -chdir=$(TF_ROOT_DIR) destroy $(TF_ARGUMENTS)

plan-destroy: ## Check changes to the cluster in destroy phase. Filter with TF_TARGET
	@terraform -chdir=$(TF_ROOT_DIR) plan -destroy $(TF_ARGUMENTS)

refresh: ## Update the state on the backend. Filter with TF_TARGET
	@terraform -chdir=$(TF_ROOT_DIR) refresh $(TF_ARGUMENTS)

generate-inventory:
	scripts/tfstate_to_ansible_inventory.py -o $(TF_INVENTORY_DIR) -e "$(ENVIRONMENT)" $(GENERATE_INVENTORY_ARGS)

