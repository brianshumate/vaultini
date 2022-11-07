MY_NAME_IS := [vaultini]
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VAULTINI_AUDIT_LOGS = ./containers/vaultini?/logs/*
VAULTINI_DATA = ./containers/vaultini?/data/*
VAULTINI_INIT = ./.vaultini?_init
VAULTINI_LOG_FILE = ./vaultini.log

default: all

all: prerequisites provision vault_status unseal_nodes audit_device done

done:
	@echo "$(MY_NAME_IS) Export VAULT_ADDR for the active node: export VAULT_ADDR=https://127.0.0.1:8200"
	@echo "$(MY_NAME_IS) Login to Vault with initial root token: vault login $$(grep 'Initial Root Token' ./.vaultini1_init | awk '{print $$NF}')"

VAULT_BINARY_OK=$$(which vault > /dev/null 2>&1 ; echo $$?)
prerequisites:
	@if [ $(VAULT_BINARY_OK) -ne 0 ] ; then echo "$(MY_NAME_IS) Vault binary not found in path. Please install Vault and try again." ; exit 1 ; fi

provision:
	@printf "$(MY_NAME_IS) Initializing Terraform workspace ..."
	@terraform init > $(VAULTINI_LOG_FILE)
	@echo 'Done.'
	@printf "$(MY_NAME_IS) Applying Terraform configuration ..."
	@terraform apply -auto-approve >> $(VAULTINI_LOG_FILE)
	@echo 'Done.'

UNSEAL_KEY=$$(grep 'Unseal Key 1' ./.vaultini1_init | awk '{print $$NF}')
unseal_nodes:
	@printf "$(MY_NAME_IS) Unsealing cluster nodes ..."
	@until [ $$(VAULT_ADDR=https://127.0.0.1:8220 vault status | grep "Initialized" | awk '{print $$2}') == "true" ] ; do sleep 1 ; printf . ; done
	@VAULT_ADDR=https://127.0.0.1:8220 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini2. '
	@until [ $$(VAULT_ADDR=https://127.0.0.1:8230 vault status | grep "Initialized" | awk '{print $$2}') == "true" ] ; do sleep 1 ; printf . ; done
	@VAULT_ADDR=https://127.0.0.1:8230 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini3. '
	@until [ $$(VAULT_ADDR=https://127.0.0.1:8240 vault status | grep "Initialized" | awk '{print $$2}') == "true" ] ; do sleep 1 ; printf . ; done
	@VAULT_ADDR=https://127.0.0.1:8240 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini4. '
	@until [ $$(VAULT_ADDR=https://127.0.0.1:8250 vault status | grep "Initialized" | awk '{print $$2}') == "true" ] ; do sleep 1 ; printf . ; done
	@VAULT_ADDR=https://127.0.0.1:8250 vault operator unseal $(UNSEAL_KEY) >> $(VAULTINI_LOG_FILE)
	@printf 'vaultini5. '
	@echo 'Done.'

ROOT_TOKEN=$$(grep 'Initial Root Token' ./.vaultini1_init | awk '{print $$NF}')
audit_device:
	@printf "$(MY_NAME_IS) Enable audit device ..."
	@VAULT_ADDR=https://127.0.0.1:8220 VAULT_TOKEN=$(ROOT_TOKEN) vault audit enable file file_path=/vault/logs/vault_audit.log > /dev/null 2>&1
	@echo 'Done.'

vault_status:
	@printf "$(MY_NAME_IS) Checking Vault active node status ..."
	@until [ $$(vault status > /dev/null 2>&1 ; echo $$?) -eq 0 ] ; do sleep 1 && printf . ; done
	@echo 'Done.'
	@printf "$(MY_NAME_IS) Checking Vault initialization status ..."
	@until [ $$(vault status | grep "Initialized" | awk '{print $$2}') == "true" ] ; do sleep 1 ; printf . ; done
	@echo 'Done.'

clean:
	@printf "$(MY_NAME_IS) Destroying Terraform configuration ..."
	@terraform destroy -auto-approve >> $(VAULTINI_LOG_FILE)
	@echo 'Done.'
	@printf "$(MY_NAME_IS) Removing artifacts created by Vaultini ..."
	@rm -rf $(VAULTINI_DATA)
	@rm -f $(VAULTINI_INIT)
	@rm -rf $(VAULTINI_AUDIT_LOGS)
	@rm -f $(VAULTINI_LOG_FILE)
	@echo 'Done.'

cleanest: clean
	@printf "$(MY_NAME_IS) Removing all Terraform runtime configuration and state ..."
	@rm -f terraform.tfstate
	@rm -f terraform.tfstate.backup
	@rm -rf .terraform
	@rm -f .terraform.lock.hcl
	@echo 'Done.'

.PHONY: all
