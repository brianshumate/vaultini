# -----------------------------------------------------------------------
# Docker network
# -----------------------------------------------------------------------

/*
resource "docker_network" "vaultini_network" {
  name            = "vaultini_network"
  attachable      = true
  check_duplicate = true
  ipam_config {
    subnet = "10.1.42.0/24"
  }
}
*/

# -----------------------------------------------------------------------
# Caddy image
# -----------------------------------------------------------------------
resource "docker_image" "caddy" {
  name         = "caddy:latest"
  keep_locally = true
}

# -----------------------------------------------------------------------
# Caddy container resources
# -----------------------------------------------------------------------

resource "docker_container" "caddy" {
  name     = "loadbalancer"
  hostname = "loadbalancer.vaultini.lan"
  env      =  []
  command = []
  image    = docker_image.caddy.repo_digest
  must_run = true
  rm       = false

  # capabilities {
  #   add = ["NET_ADMIN"]
  # }

  # healthcheck {
  #   test         = ["CMD", "vault", "status"]
  #   interval     = "10s"
  #   timeout      = "2s"
  #   start_period = "10s"
  #   retries      = 2
  # }

  networks_advanced {
    #name         = docker_network.vaultini_network.name
    name         = "vaultini_network"
    ipv4_address = "10.1.42.10"
  }

  ports {
    internal = 8443
    external = 8443
    protocol = "tcp"
  }

  volumes {
    host_path      = "${path.cwd}/containers/caddy/conf"
    container_path = "/etc/caddy"
  }

  volumes {
    host_path      = "${path.cwd}/containers/caddy/data"
    container_path = "/data"
  }

  volumes {
    host_path      = "${path.cwd}/containers/caddy/logs"
    container_path = "/var/log/caddy"
  }

}
