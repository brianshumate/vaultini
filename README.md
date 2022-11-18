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

Vaultini is a minimal 5-node [Vault](https://www.vaultproject.io) cluster running the official [OSS Docker image](https://hub.docker.com/_/vault/) with [Integrated Storage](https://developer.hashicorp.com/vault/docs/configuration/storage/raft) on [Docker](https://www.docker.com/products/docker-desktop/). It is powered by a `Makefile`, [Terraform CLI](https://developer.hashicorp.com/terraform/cli), and the [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

## Why?

To quickly establish a containerized Vault cluster with [Integrated Storage](https://developer.hashicorp.com/vault/docs/configuration/storage/raft) for development, education, and testing.

## How?

You can make your own Vaultini with Docker, Terraform, and the Terraform Docker provider.

### Prerequisites

To make a Vaultini, your host computer must have the following software installed:

- [Docker](https://www.docker.com/products/docker-desktop/) (tested with Docker Desktop version 4.14.0 on macOS version 12.6.1)

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) binary installed in your system PATH (tested with version 1.3.5 darwin_arm64 on macOS version 12.6.1)

> **NOTE:** Vaultini is currently known to function on Linux (last tested on Ubuntu 22.04) and macOS with Intel or Apple silicon processors.

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

   - For Linux:

     - **Alpine**

        Update the package cache and install the `ca-certificates` package.

        ```shell
        $ sudo apk update && sudo apk add ca-certificates
        fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/aarch64/APKINDEX.tar.gz
        fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/aarch64/APKINDEX.tar.gz
        v3.14.8-86-g0df2022316 [https://dl-cdn.alpinelinux.org/alpine/v3.14/main]
        v3.14.8-86-g0df2022316 [https://dl-cdn.alpinelinux.org/alpine/v3.14/community]
        OK: 14832 distinct packages available
        OK: 9 MiB in 19 packages
        ```

        From within this repository directory, copy the Vaultini CA certificate to the `/usr/local/share/ca-certificates` directory.

        ```shell
        $ sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
            /usr/local/share/ca-certificates/vaultini-ca.crt
        # No output expected
        ```

        Append the certificates to the file `/etc/ssl/certs/ca-certificates.crt`.

        ```shell
        $ sudo sh -c "cat /usr/local/share/ca-certificates/vaultini-ca.crt >> /etc/ssl/certs/ca-certificates.crt"
        # No output expected
        ```

        Update certificates.

        ```shell
        $ sudo sudo update-ca-certificates
        # No output expected
        ```

     - **Debian & Ubuntu**

        Install the `ca-certificates` package.

        ```shell
        $ sudo apt-get install -y ca-certificates
         Reading package lists... Done
         ...snip...
         Updating certificates in /etc/ssl/certs...
         0 added, 0 removed; done.
         Running hooks in /etc/ca-certificates/update.d...
         done.
        ```

       Copy the Vaultini CA certificate to `/usr/local/share/ca-certificates`.

       ```shell
       $ sudo cp containers/vaultini1/certs/vaultini-ca.pem \
           /usr/local/share/ca-certificates/vaultini-ca.crt
       # No output expected
       ```

       Update certificates.

       ```shell
       $ sudo update-ca-certificates
       Updating certificates in /etc/ssl/certs...
       1 added, 0 removed; done.
       Running hooks in /etc/ca-certificates/update.d...
       done.
       ```

     - **RHEL**

       From within this repository directory, copy the Vaultini CA certificate to the `/etc/pki/ca-trust/source/anchors` directory.

        ```shell
        $ sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
            /etc/pki/ca-trust/source/anchors/vaultini-ca.crt
        # No output expected
        ```

        Update CA trust.

        ```shell
        $ sudo update-ca-trust
        # No output expected
        ```

       From within this repository directory, copy the Vaultini CA certificate to the `/usr/local/share/ca-certificates` directory.

        ```shell
        $ sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
            /usr/local/share/ca-certificates/vaultini-ca.crt
        # No output expected
        ```

        Update certificates.

        ```shell
        $ sudo update-ca-certificates
        # No output expected
        ```

4. Type `make` and press `[return]`; successful output resembles this example and includes the initial root token value for the sake of convenience and ease of use:

   ```plaintext
   [vaultini] Initializing Terraform workspace ...Done.
   [vaultini] Applying Terraform configuration ...Done.
   [vaultini] Checking Vault active node status ...Done.
   [vaultini] Checking Vault initialization status ...Done.
   [vaultini] Unsealing cluster nodes .....vaultini2. vaultini3. vaultini4. vaultini5. Done.
   [vaultini] Enable audit device ...Done.
   [vaultini] Export VAULT_ADDR for the active node: export VAULT_ADDR=https://127.0.0.1:8200
   [vaultini] Login to Vault with initial root token: vault login hvs.E5DA1IvLTq9y1q8p1Oc0ff33
   ```

5. Follow the instructions to set an appropriate `VAULT_ADDR` environment variable, and login to Vault with the initial root token value.

### Cleanup

To clean up Docker containers and all generated artifacts, **including audit device log files**:

```shell
make clean
```

To clean up **everything** including Terraform runtime configuration and state:

```shell
make cleanest
```

To remove the CA certificate from your OS trust store:

- For macOS:

  ```shell
  $ sudo security delete-certificate -c "vaultini Intermediate Authority"
  # no output expected
  ```

  - You will be prompted for your user password; enter it to add the certificate.

- For Linux:

  - Follow the documentation for your specific Linux distribution to remove the certificate.

### Notes

The following notes should help you to better understand the container structure used by Vaultini along with tips on commonly used features like specifying the Vault version to use, and more.

#### Configuration, data & logs

The configuration, data, and audit device log files live in a subdirectory under `containers` that is named after the server. For example, here is the structure of the first server, _vaultini1_ as it appears when active.

```shell
$ tree containers/vaultini1
containers/vaultini1
├── certs
│   ├── server-cert.pem
│   ├── server-key.pem
│   ├── vaultini-ca-chain.pem
│   └── vaultini-ca.pem
├── config
│   └── server.hcl
├── data
│   ├── raft
│   │   ├── raft.db
│   │   └── snapshots
│   └── vault.db
└── logs
    └── vault_audit.log

6 directories, 8 files
```

#### Run a specific Vault version

Vaultini tries to keep current and offer the latest available Vault Docker image version, but you can also run a specific version of Vault with the `TF_VAR_vault_version` environment variable like this:. 

```shell
TF_VAR_vault_version=1.11.0 make
```

> **Tip**: Versions >= 1.11.0 are recommended for ideal Integrated Storage support.

#### Set the Vault server log level

The default Vault server log level is Info, but you can specify another log level like `Debug`, with the `TF_VAR_vault_log_level` environment variable like this:

```shell
TF_VAR_vault_log_level=Debug make
```

### What next?

A great resource for learning more about Vault is the [HashiCorp Developer](https://developer.hashicorp.com) site, which has a nice [Vault tutorial library](https://developer.hashicorp.com/tutorials/library?product=vault) available.

If you are completely new to Vault, check out the Get Started series:

- [CLI Quick Start](https://developer.hashicorp.com/vault/tutorials/getting-started)
- [HCP Vault Quick Start](https://developer.hashicorp.com/vault/tutorials/cloud)
- [UI Quick Start](https://developer.hashicorp.com/vault/tutorials/getting-started-ui)

The tutorial library also has a wide range of intermediate and advanced tutorials with integrated hands on labs.

Be sure to explore them all!

## Who?

- [Brian Shumate](https://github.com/brianshumate)
