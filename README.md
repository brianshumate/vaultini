# Vaultini

Vaultini is a minimal Vault cluster Terraformed onto Docker containers.

You can use Vaultini for development and testing, but you should **never try to use it for production use cases**.

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

1. Export the VAULT_CACERT environment variable to point to the Vaultini Certificate Authority file:

     ```shell
     export VAULT_CACERT="$PWD/containers/vaultini1/certs/vaultini-ca.pem"
     ```

2. Type `make` and press `[return]`; successful output resembles this example, and includes the unseal key and initial root token value for convenience:

   ```plaintext
   [vaultini] Initializing Terraform workspace ...Done.
   [vaultini] Applying Terraform configuration ...Done.
   [vaultini] Checking Vault active node status ...Done.
   [vaultini] Checking Vault initialization status ...Done.
   [vaultini] Unsealing cluster nodes .....vaultini2. vaultini3. vaultini4. vaultini5. Done.
   [vaultini] Enable audit device ...Done.
   [vaultini] Export VAULT_ADDR for the load balancer : export VAULT_ADDR=https://localhost:8443
   [vaultini] Unseal key for nodes: 3YUzzSnKmc0ff33scy8WrUtbojl/3liGfoDxQ/lEYZs=
   [vaultini] Login to Vault with initial root token: vault login hvs.cY2NrVSnfhrOvp80F0c0ff33
   ```

3. Follow the instructions to set the correct `VAULT_ADDR` environment variable, and login to Vault with the initial root token value.

### Cleanup

To clean up Docker containers and all generated artifacts, **including audit device log files**:

```shell
make clean
```

To clean up **everything** including Terraform runtime configuration and state:

```shell
make cleanest
```

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

Make Vaultini:

```shell
make
```

#### Set the Vault server log level

The default Vault server log level is Info, but you can specify another log level like `Debug`, with the `TF_VAR_vault_log_level` environment variable like this:

```shell
TF_VAR_vault_log_level=Debug make
```

## Next steps

New to Vault and unsure what to do next?

- [Get started with Vault foundations](https://developer.hashicorp.com/vault/tutorials/get-started)

- Dive into some of the [available tutorials](https://developer.hashicorp.com/tutorials/library?product=vault?ref=BrianShumateDotCom) on the HashiCorp Developer site.

You can  use Vaultini as your dev mode Vault server right now for many of the tutorial scenarios.

Enjoy!

## Who?

- [Brian Shumate](https://github.com/brianshumate)
