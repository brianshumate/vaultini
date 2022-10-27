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

Vaultini is a minimal 5-node Vault cluster running the OSS edition with Integrated Storage on Docker. It is powered by a `Makefile`, [Terraform CLI](https://developer.hashicorp.com/terraform/cli), and the [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

## Why?

To quickly establish a containerized Vault cluster with Integrated Storage for development, education, and testing purposes.

## How?

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

### Cleanup

To clean up Docker containers and all generated artifacts:

```shell
make clean
```

To clean up **everything** including Terraform runtime configuration and state:

```shell
make cleanest
```

### Specific Vault version

Run a specific version of Vault >= 1.7.0.

```shell
TF_VAR_vault_version=1.11.0 make
```

## Who?

[Brian Shumate](https://github.com/brianshumate)
