# Vaultini

Vaultini is a minimal Vault cluster Terraformed onto Docker containers.

You can use Vaultini for development and testing, but you shouldn't use it for production use cases.

## What?

Vaultini builds and runs a minimally configured 5-node [Vault](https://www.vaultproject.io) cluster on the official [Vault Docker image](https://hub.docker.com/_/vault/) with [Integrated Storage](https://developer.hashicorp.com/vault/docs/configuration/storage/raft) on [Docker](https://www.docker.com/products/docker-desktop/).

A `Makefile`, [Terraform CLI](https://developer.hashicorp.com/terraform/cli), and the [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs) power the project, and bootstraps the cluster.

## Why?

Vaultini can quickly establish a containerized Vault cluster useful for development, education, and testing. The cluster is fully initialized, joined, and unsealed; once provisioned, you can immediately start using it.

## How?

You can make your own Vaultini with Docker, Terraform, and the Terraform Docker provider.

### Prerequisites

To make a Vaultini, you need the following:

- Linux or macOS

- [Docker](https://www.docker.com/products/docker-desktop/) (tested with Docker Desktop version 4.31.0 on macOS version 14.5)

- [git](https://git-scm.com)

- BSD make or [gnumake](https://www.gnu.org/software/make/)

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) binary installed in your system PATH (tested with version 1.6.3 darwin_arm64)

- [Vault](https://releases.hashicorp.com/vault) You can use the Vault CLI as client to Vaultini instead of `docker exec vault ...`.

> **NOTE:** Vaultini works with Linux (tested on Ubuntu 22.04) and macOS with Intel or Apple silicon processors.

### Make your own Vaultini

Follow these steps to make your own Vaultini.

1. Clone this repository.

1. `cd vaultini`

1. Add the Vaultini Certificate Authority to your OS trust store:

   - **For macOS**

     ```shell
     sudo security add-trusted-cert -d -r trustAsRoot \
        -k /Library/Keychains/System.keychain \
        ./containers/vaultini1/certs/vaultini-ca.pem
     ```

       - The `sudo` command prompts for your user password and sometimes prompts twice; enter your user password to add the certificate.

   - **For Linux**

     - Alpine Linux

       - Update the package cache and install the `ca-certificates` package.

          ```shell
          sudo apk update && sudo apk add ca-certificates
          ```

       - From within this repository directory, copy the Vaultini CA certificate to the `/usr/local/share/ca-certificates` directory.

          ```shell
          sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
              /usr/local/share/ca-certificates/vaultini-ca.crt
          ```

       - Update the certificates database.

          ```shell
          sudo sudo update-ca-certificates
          ```

     - Debian & Ubuntu

        Install the `ca-certificates` package.

        ```shell
        sudo apt install -y ca-certificates
        ```

       Copy the Vaultini CA certificate to `/usr/local/share/ca-certificates`.

       ```shell
       sudo cp containers/vaultini1/certs/vaultini-ca.pem \
           /usr/local/share/ca-certificates/vaultini-ca.crt
       ```

       Update certificates.

       ```shell
       sudo update-ca-certificates
       ```

     - Red Hat Enterprise Linux

       From within this repository directory, copy the Vaultini CA certificate to the `/etc/pki/ca-trust/source/anchors` directory.

        ```shell
        sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
            /etc/pki/ca-trust/source/anchors/vaultini-ca.crt
        ```

        Update CA trust.

        ```shell
        sudo update-ca-trust
        ```

       From within this repository directory, copy the Vaultini CA certificate to the `/usr/local/share/ca-certificates` directory.

        ```shell
        sudo cp ./containers/vaultini1/certs/vaultini-ca.pem \
            /usr/local/share/ca-certificates/vaultini-ca.crt
        ```

        Update certificates.

        ```shell
        sudo update-ca-certificates
        ```

1. Type `make` and press `[return]`; successful output resembles this example, and includes the initial root token value for the sake of convenience and ease of use:

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

1. Follow the instructions to set an appropriate `VAULT_ADDR` environment variable, and login to Vault with the initial root token value.

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
  sudo security delete-certificate -c "vaultini Intermediate Authority"
  ```

  - The `sudo` command prompts for your user password; enter your user password to add the certificate.

- For Linux:

  - Follow the documentation for your specific Linux distribution to remove the certificate.

### Notes

The following notes describe the container structure Vaultini uses, provide some tips on common features.

#### Configuration, data & logs

The configuration, data, and audit device log files live in a subdirectory under `containers` named for the server. For example, the first server, _vaultini1_ has a directory and file structure like the following when active.

```shell
tree containers/vaultini1
```

Example output:

```plaintext
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

Vaultini tries to keep current and offer the latest available Vault Docker image version, but you can also run a specific version of Vault with the `TF_VAR_vault_version` environment variable.

```shell
TF_VAR_vault_version=1.11.0 make
```

> **Tip**: Use Vault versions >= 1.11.0 for ideal Integrated Storage support.

#### Run Vault Enterprise

Vaultini runs the Vault Community Edition by default, but you can also run the Enterprise edition.

> **NOTE**:
> You must have an [Enterprise license](https://www.hashicorp.com/products/vault/pricing) to run the Vault Enterprise image.

Export the `TF_VAR_vault_license` environment variable with your Vault Enterprise license string as the value. For example:

```shell
export TF_VAR_vault_license=02E2VCBORGUIRSVJVCECNSNI...
```

Export the `TF_VAR_vault_edition` environment variable to specify `vault-enterprise` as the value.

```shell
export TF_VAR_vault_edition=vault-enterprise
```

Make Vaultini

```shell
make
```

#### Set the Vault server log level

The default Vault server log level is Info, but you can specify another log level like `Debug`, with the `TF_VAR_vault_log_level` environment variable like this:

```shell
TF_VAR_vault_log_level=Debug make
```

### What next?

A great resource for learning more about Vault is the [HashiCorp Developer](https://developer.hashicorp.com) site, which has a nice [Vault tutorial library](https://developer.hashicorp.com/tutorials/library?product=vault) available.

If you are new to Vault, check out the Get Started series:

- [CLI Quick Start](https://developer.hashicorp.com/vault/tutorials/getting-started)
- [HCP Vault Quick Start](https://developer.hashicorp.com/vault/tutorials/cloud)
- [UI Quick Start](https://developer.hashicorp.com/vault/tutorials/getting-started-ui)

The tutorial library also has a wide range of intermediate and advanced tutorials with integrated hands on labs for you to explore.

## Who?

- [Brian Shumate](https://github.com/brianshumate)
