# Vaultini

```plaintext
  ooooo  oooo                    o888   o8   o88               o88
   888    88 ooooooo oooo  oooo   888 o888oo oooo  oo oooooo   oooo
    888  88  ooooo888 888   888   888  888    888   888   888   888
     88888 888    888 888   888   888  888    888   888   888   888
      888   88ooo88 8o 888o88 8o o888o  888o o888o o888o o888o o888o

oooo8oooo8oooo8oooo8ooooo8ooooo8ooooo8ooooo8ooooo8ooooo8ooooo8oooo8ooo

Vaultini is a minimal Vault cluster Terraformed onto Docker containers.
It is useful for development and testing, but not for production.

oooo8oooo8oooo8oooo8ooooo8ooooo8ooooo8ooooo8ooooo8ooooo8ooooo8oooo8ooo
```

## What?

Vaultini is a minimal 5-node Vault cluster running the official [OSS Docker image](https://hub.docker.com/_/vault/) with [Integrated Storage](https://developer.hashicorp.com/vault/docs/configuration/storage/raft) on [Docker](https://www.docker.com/products/docker-desktop/). It is powered by a `Makefile`, [Terraform CLI](https://developer.hashicorp.com/terraform/cli), and the [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

## Why?

To quickly establish a containerized Vault cluster with Integrated Storage for development, education, and testing purposes.

## How?

Making your own Vaultini is a quick process once you have the required prerequisites.

### Establish prerequisites

To make a Vaultini, your host computer must have the following software installed:

- [Docker](https://www.docker.com/products/docker-desktop/) (tested with Docker Desktop version 4.12.0 on macOS version 12.6)

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) binary installed in your system PATH (tested with version 1.3.3 on darwin_arm64)

> **NOTE:** Vaultini is currently known to function on macOS, with planned support for additional operating systems going forward.

### Make your own Vaultini

There are just a handful of steps to make your own Vaultini.

1. Clone this repository.

2. `cd vaultini`

3. Add the Vaultini Certificate Authority certificate to your operating system trust store:

   - For macOS:

   ```shell
   $ sudo security add-trusted-cert -d -r trustAsRoot \
      -k /Library/Keychains/System.keychain \
      ./containers/vaultini1/certs/vaultini-ca.pem
   ```

     - You will be prompted for your user password; enter it to add the certificate.

4. Type `make` and press [return].

5. Follow the instructions.

### Specific Vault version

You can run a specific version of Vault >= 1.7.0; Versions >= 1.11.0 are recommended for ideal Integrated Storage support.

```shell
TF_VAR_vault_version=1.11.0 make
```

### Cleanup

To clean up Docker containers and all generated artifacts:

```shell
make clean
```

To clean up **everything** including Terraform runtime configuration and state:

```shell
make cleanest
```

## Who?

[Brian Shumate](https://github.com/brianshumate)
