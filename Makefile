THIS_FILE := $(lastword $(MAKEFILE_LIST))
VAULTINI_DATA = ./containers/vaultini?/data/*
VAULTINI_INIT = ./.vaultini?_init
VAULTINI_LOG_FILE = ./vaultini.log

default: all

all: provision unseal

provision:
	@printf 'Initializing Terraform workspace ...'
	@terraform init > $(VAULTINI_LOG_FILE)
	@echo 'Done.'
	@printf 'Applying Terraform configuration ...'
	@terraform apply -auto-approve >> $(VAULTINI_LOG_FILE)
	@echo 'Done.'

UNSEAL_KEY=$$(grep 'Unseal Key 1' ./.vaultini1_init | awk '{print $$NF}')
unseal:
	@sleep 5
	@printf 'Unsealing cluster nodes ... '
	@VAULT_ADDR=https://127.0.0.1:8220 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini2. '
	@VAULT_ADDR=https://127.0.0.1:8230 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini3. '
	@VAULT_ADDR=https://127.0.0.1:8240 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini4. '
	@VAULT_ADDR=https://127.0.0.1:8250 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini5. '
	@echo 'Done.'
	@echo 'Set the appropriate VAULT_ADDR to address the active node with this export command:'
	@echo 'export VAULT_ADDR=https://127.0.0.1:8200'
	@echo "Initial root token: $$(grep 'Initial Root Token' ./.vaultini1_init | awk '{print $$NF}')"

clean:
	@printf 'Destroying Terraform configuration ...'
	@terraform destroy -auto-approve >> $(VAULTINI_LOG_FILE)
	@echo 'Done.'
	@printf 'Removing files created by Vaultini ...'
	@rm -rf $(VAULTINI_DATA)
	@rm -f $(VAULTINI_INIT)
	@rm -f $(VAULTINI_LOG_FILE)
	@echo 'Done.'

cleanest: clean
	@printf 'Removing all Terraform runtime configuration and state ...'
	@rm -f terraform.tfstate
	@rm -f terraform.tfstate.backup
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@echo 'Done.'

.PHONY: all
