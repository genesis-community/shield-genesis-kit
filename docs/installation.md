# Installing SHIELD Genesis Kit

This guide walks you through the process of installing and deploying SHIELD using the Genesis Kit.

## Prerequisites

Before you begin, you'll need:

1. **BOSH Director**: A running BOSH director with appropriate cloud-config
2. **Genesis**: Genesis v2.7.6 or higher installed
3. **Cloud Infrastructure**: Access to supported cloud infrastructure (AWS, vSphere, GCP, STACKIT)
4. **Network**: A network with a reserved static IP for SHIELD

## Step 1: Install Genesis

If you haven't already installed Genesis, do so by following the [Genesis installation instructions](https://github.com/genesis-community/genesis).

The SHIELD Genesis Kit requires Genesis v2.7.6 or higher:

```bash
# Check your Genesis version
genesis -v

# If needed, upgrade Genesis
```

## Step 2: Initialize a SHIELD Deployment Repository

Create a new deployment repository using the SHIELD Genesis Kit:

```bash
# Create a new repo with the latest version of the kit
genesis init --kit shield

# Or specify a specific version
genesis init --kit shield/1.9.0

# Optionally specify a custom directory name
genesis init --kit shield -d my-shield-configs
```

This creates a new Git repository with the necessary structure for deploying SHIELD.

## Step 3: Create an Environment File

Navigate to your new deployment repository and create an environment file for your deployment:

```bash
cd shield-deployments  # or your custom directory name
genesis new my-env
```

Edit the generated environment file (found in `my-env.yml`) to include the necessary parameters:

```yaml
---
kit:
  name: shield
  version: 1.9.0
  features:
    - secure  # Optional: generate secure admin credentials

genesis:
  env: my-env

params:
  shield_static_ip: 10.0.0.7  # Replace with your static IP
  shield_network: shield      # Replace with your network name
  shield_vm_type: small       # Replace with your VM type
  shield_disk_pool: shield    # Replace with your disk pool
  external_domain: shield.example.com  # Optional: your domain for SHIELD
```

## Step 4: Verify Cloud Config

Ensure your BOSH director's cloud config includes the necessary resources:

```bash
# Check your current cloud config
bosh cloud-config

# If needed, update your cloud config to include the required resources
```

The cloud config should define:
- The network specified in `shield_network`
- The VM type specified in `shield_vm_type`
- The disk pool specified in `shield_disk_pool`
- An availability zone (defaults to `z1`)

## Step 5: Deploy SHIELD

Deploy SHIELD using Genesis:

```bash
genesis deploy my-env
```

This will:
1. Generate the BOSH manifest
2. Deploy SHIELD via BOSH
3. Set up the necessary certificates and credentials

## Step 6: Access SHIELD

Once deployed, access your SHIELD instance:

```bash
# Get the SHIELD URL
genesis do my-env -- info

# Open SHIELD in your browser (macOS only)
genesis do my-env -- visit
```

### Initial Login

- If using the default authentication, log in with username `admin` and password `shield`
- If using the `secure` feature, retrieve the password from Vault:
  ```bash
  genesis do my-env -- vault get secret/path/to/failsafe:admin_password
  ```
- If using OAuth, follow the OAuth login flow through your configured provider

## Step 7: Additional Configuration

After deployment, consider these next steps:

1. **Deploy SHIELD Agents**: Set up agents on systems you want to back up
   ```bash
   genesis do my-env -- addon runtime-config
   ```

2. **Configure Targets**: Set up backup targets in the SHIELD UI

3. **Configure Storage**: Set up storage backends in the SHIELD UI

4. **Create Jobs**: Set up backup jobs with schedules

## Upgrading SHIELD

To upgrade an existing SHIELD deployment:

1. Update the kit version in your environment file:
   ```yaml
   kit:
     version: 1.9.0  # Specify the new version
   ```

2. Deploy the updated version:
   ```bash
   genesis deploy my-env
   ```

## Next Steps

- Review the [Quick Start Guide](quickstart.md) for basic usage instructions
- Configure [Authentication](features/authentication.md) for your organization
- Learn about [PostgreSQL Integration](features/postgres.md) for larger deployments