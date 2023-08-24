# -----------------------------------------------------------------------
# Global variables
# -----------------------------------------------------------------------

# Set TF_VAR_docker_host to override this
# tcp with hostname example:
# export TF_VAR_docker_host="tcp://docker:2345"

variable "docker_host" {
    default = "unix:///var/run/docker.sock"
}

# -----------------------------------------------------------------------
# Vault variables
# -----------------------------------------------------------------------

# Set TF_VAR_vault_version to override this
variable "vault_version" {
    default = "1.14.1"
}

# Set TF_VAR_vault_log_level to override this
variable "vault_log_level" {
    default = "info"
}
