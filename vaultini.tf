#  __  __                     ___    __
# /\ \/\ \                   /\_ \  /\ \__  __          __
# \ \ \ \ \     __     __  __\//\ \ \ \ ,_\/\_\    ___ /\_\
#  \ \ \ \ \  /'__`\  /\ \/\ \ \ \ \ \ \ \/\/\ \ /' _ `\/\ \
#   \ \ \_/ \/\ \L\.\_\ \ \_\ \ \_\ \_\ \ \_\ \ \/\ \/\ \ \ \
#    \ `\___/\ \__/.\_\\ \____/ /\____\\ \__\\ \_\ \_\ \_\ \_\
#     `\/__/  \/__/\/_/ \/___/  \/____/ \/__/ \/_/\/_/\/_/\/_/
#
#
# Vaultini is a minimal Vault cluster Terraformed onto Docker containers.
# It is useful for development and testing, but not for production.

# -----------------------------------------------------------------------
# Provider configuration
# -----------------------------------------------------------------------

provider "docker" {
    host = var.docker_host
}
# -----------------------------------------------------------------------
# Docker network
# -----------------------------------------------------------------------

resource "docker_network" "vaultini_network" {
  name            = "vaultini_network"
  attachable      = true
  check_duplicate = true
  ipam_config {
    subnet = "10.1.42.0/24"
  }
}

# -----------------------------------------------------------------------
# Vault image
# -----------------------------------------------------------------------

resource "docker_image" "vault" {
    name         = "hashicorp/${var.vault_edition}:latest"
    keep_locally = true
}

# -----------------------------------------------------------------------
# Vault container resources
# -----------------------------------------------------------------------

locals {
 vault_containers = {
   "vaultini1" = { ipv4_address = "10.1.42.101", env = ["SKIP_CHOWN", "VAULT_LICENSE=${var.vault_license}", "VAULT_CLUSTER_ADDR=https://10.1.42.101:8201", "VAULT_REDIRECT_ADDR=https://10.1.42.101:8200","VAULT_CACERT=/vault/certs/vaultini-ca.pem"], internal_port = "8200", external_port = "8200", host_path_certs = "${path.cwd}/containers/vaultini1/certs", host_path_config = "${path.cwd}/containers/vaultini1/config", host_path_data = "${path.cwd}/containers/vaultini1/data", host_path_logs = "${path.cwd}/containers/vaultini1/logs"},
   "vaultini2" = { ipv4_address = "10.1.42.102", env = ["SKIP_CHOWN", "VAULT_LICENSE=${var.vault_license}", "VAULT_CLUSTER_ADDR=https://10.1.42.102:8201", "VAULT_REDIRECT_ADDR=https://10.1.42.102:8200","VAULT_CACERT=/vault/certs/vaultini-ca.pem"], internal_port = "8200", external_port = "8220", host_path_certs = "${path.cwd}/containers/vaultini2/certs", host_path_config = "${path.cwd}/containers/vaultini2/config", host_path_data = "${path.cwd}/containers/vaultini2/data", host_path_logs = "${path.cwd}/containers/vaultini2/logs"},
   "vaultini3" = { ipv4_address = "10.1.42.103", env = ["SKIP_CHOWN", "VAULT_LICENSE=${var.vault_license}", "VAULT_CLUSTER_ADDR=https://10.1.42.103:8201", "VAULT_REDIRECT_ADDR=https://10.1.42.103:8200","VAULT_CACERT=/vault/certs/vaultini-ca.pem"], internal_port = "8200", external_port = "8230", host_path_certs = "${path.cwd}/containers/vaultini3/certs", host_path_config = "${path.cwd}/containers/vaultini3/config", host_path_data = "${path.cwd}/containers/vaultini3/data", host_path_logs = "${path.cwd}/containers/vaultini3/logs"},
   "vaultini4" = { ipv4_address = "10.1.42.104", env = ["SKIP_CHOWN", "VAULT_LICENSE=${var.vault_license}", "VAULT_CLUSTER_ADDR=https://10.1.42.104:8201", "VAULT_REDIRECT_ADDR=https://10.1.42.104:8200","VAULT_CACERT=/vault/certs/vaultini-ca.pem"], internal_port = "8200", external_port = "8240", host_path_certs = "${path.cwd}/containers/vaultini4/certs", host_path_config = "${path.cwd}/containers/vaultini4/config", host_path_data = "${path.cwd}/containers/vaultini4/data", host_path_logs = "${path.cwd}/containers/vaultini4/logs"},
   "vaultini5" = { ipv4_address = "10.1.42.105", env = ["SKIP_CHOWN", "VAULT_LICENSE=${var.vault_license}", "VAULT_CLUSTER_ADDR=https://10.1.42.105:8201", "VAULT_REDIRECT_ADDR=https://10.1.42.105:8200","VAULT_CACERT=/vault/certs/vaultini-ca.pem"], internal_port = "8200", external_port = "8250", host_path_certs = "${path.cwd}/containers/vaultini5/certs", host_path_config = "${path.cwd}/containers/vaultini5/config", host_path_data = "${path.cwd}/containers/vaultini5/data", host_path_logs = "${path.cwd}/containers/vaultini5/logs"}
 }
}

resource "docker_container" "vaultini" {
  for_each = local.vault_containers
  name     = each.key
  hostname = each.key
  env      = each.value.env
  command  = ["vault",
              "server",
              "-config",
              "/vault/config/server.hcl",
              "-log-level",
              "${var.vault_log_level}"
              ]
  image    = docker_image.vault.repo_digest
  must_run = true
  rm       = true

  capabilities {
    add = ["IPC_LOCK", "SYSLOG"]
  }

  healthcheck {
    test         = ["CMD", "vault", "status"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }

  networks_advanced {
    name         = "${docker_network.vaultini_network.name}"
    ipv4_address = each.value.ipv4_address
  }

  ports {
    internal = each.value.internal_port
    external = each.value.external_port
    protocol = "tcp"
  }

  volumes {
    host_path      = each.value.host_path_certs
    container_path = "/vault/certs"
  }

  volumes {
    host_path      = each.value.host_path_config
    container_path = "/vault/config"
  }

  volumes {
    host_path      = each.value.host_path_data
    container_path = "/vault/data"
  }

  volumes {
    host_path      = each.value.host_path_logs
    container_path = "/vault/logs"
  }

}

resource "null_resource" "active_node_init" {
  provisioner "local-exec" {
    command = "while ! curl --insecure --fail --silent https://127.0.0.1:8200/v1/sys/seal-status --output /dev/null ; do printf '.' ; sleep 4 ; done ; vault operator init -key-shares=1 -key-threshold=1 > ${path.cwd}/.vaultini1_init"
    environment = {
      VAULT_ADDR = "https://127.0.0.1:8200"
      VAULT_CACERT = "${path.cwd}/containers/vaultini1/certs/vaultini-ca.pem"
    }
  }

  depends_on = [
    docker_container.vaultini
  ]

}

resource "null_resource" "active_node_unseal" {
  provisioner "local-exec" {
    command = "while [ ! -f ${path.cwd}/.vaultini1_init ] ; do printf '.' ; sleep 1 ; done &&export UNSEAL_KEY=$(grep 'Unseal Key 1' ${path.cwd}/.vaultini1_init | awk '{print $NF}') && vault operator unseal $UNSEAL_KEY"
    environment = {
      VAULT_ADDR = "https://127.0.0.1:8200"
      VAULT_CACERT = "${path.cwd}/containers/vaultini1/certs/vaultini-ca.pem"
    }
  }

  depends_on = [
    null_resource.active_node_init
  ]

}
