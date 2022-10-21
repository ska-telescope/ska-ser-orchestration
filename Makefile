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
DATACENTRE?=
SERVICE?=
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

ifneq ($(DATACENTRE),)
    GENERATE_INVENTORY_ARGS := $(GENERATE_INVENTORY_ARGS) -d "$(DATACENTRE)"
endif

ifneq ($(SERVICE),)
    GENERATE_INVENTORY_ARGS := $(GENERATE_INVENTORY_ARGS) -s "$(SERVICE)"
endif

-include PrivateRules.mak

vars:  ## Current variables
	@echo "DATACENTRE=$(DATACENTRE)"
	@echo "ENVIRONMENT=$(ENVIRONMENT)"
	@echo "SERVICE=$(SERVICE)"
	@echo "GITLAB_PROJECT_ID=$(GITLAB_PROJECT_ID)"
	@echo "TF_ROOT_DIR=$(TF_ROOT_DIR)"
	@echo "TF_INVENTORY_DIR=$(TF_INVENTORY_DIR)"
	@echo "TF_TARGET=$(TF_TARGET)"
	@echo "TF_HTTP_ADDRESS=$(TF_HTTP_ADDRESS)"
	@echo "TF_HTTP_LOCK_ADDRESS=$(TF_HTTP_LOCK_ADDRESS)"
	@echo "TF_HTTP_UNLOCK_ADDRESS=$(TF_HTTP_UNLOCK_ADDRESS)"

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

print_targets:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ": .*?## "}; {p=index($$1,":")} {printf "\033[36m%-30s\033[0m %s\n", substr($$1,p+1), $$2}';

help: ## Show Help
	@echo ""
	@echo "Vars:"
	@$(MAKE) vars;
	@echo ""
	@echo "Targets:"
	@$(MAKE) print_targets;