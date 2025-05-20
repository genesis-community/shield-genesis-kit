# SHIELD Genesis Kit

This is a Genesis Kit for the [SHIELD Data Protection System](https://github.com/starkandwayne/shield) from [Stark & Wayne](https://starkandwayne.com). When using [Genesis](https://github.com/starkandwayne/genesis) to deploy this kit, you will get a fully-functional SHIELD deployment for backing up and restoring your data services.

## Features

- **Core SHIELD Functionality**: Full-featured backup solution for various data stores
- **Authentication Options**: 
  - Standard username/password
  - OAuth integration (GitHub, UAA)
  - Okta integration
- **Database Options**: 
  - PostgreSQL addon for improved scalability and reliability
- **Security**: 
  - TLS encryption for all communications
  - Secure credential management
- **Cloud Provider Support**:
  - AWS
  - vSphere
  - GCP
  - STACKIT (with full OpenStack parity)

## Requirements

- BOSH Director with appropriate cloud-config
- Genesis v2.7.6 or higher

## Quick Start

To use it, you don't even need to clone this repository! Just run the following (using Genesis v2):

```bash
# Create a shield-deployments repo using the latest version of the SHIELD kit
genesis init --kit shield

# Create a shield-deployments repo using v1.9.0 of the SHIELD kit
genesis init --kit shield/1.9.0

# Create a my-shield-configs repo using the latest version of the SHIELD kit
genesis init --kit shield -d my-shield-configs
```

Once created, refer to the deployment repo's README for information on creating new environments and deploying them.

## Deployment

A typical deployment would involve:

1. Initialize the deployment repo as shown above
2. Create an environment file with appropriate parameters and features
3. Deploy with `genesis deploy <env-name>`

Example environment file:

```yaml
---
kit:
  name:    shield
  version: 1.9.0
  features:
    - secure
    - postgres-addon

genesis:
  env: acme-us-east-1-prod

params:
  shield_static_ip: 10.0.0.7
  shield_network:   core-infra
  shield_disk_pool: backups
  shield_vm_type:   std.small.1c.2gb
  postgres-addon-version: 11
```

## Available Features

- `oauth`: Enables OAuth2 authentication for SHIELD
- `postgres-addon`: Uses PostgreSQL for database storage
- `secure`: Configures the admin user account with auto-generated credentials
- `okta`: Enables Okta authentication integration

## Available Addons

- `visit`: Open up the SHIELD Web UI in your browser
- `runtime-config`: Generate a starter configuration for deploying the SHIELD agent via BOSH as an addon

## Learn More

For more in-depth documentation, check out the [manual](MANUAL.md).

## Contributing

Please see the [contribution guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

## License

This Genesis Kit is released under the [MIT License](LICENSE).

## History

This kit requires Genesis v2.7.6 or higher.

Recent updates:
- v1.9.0: Added STACKIT IaaS provider support with OpenStack parity
- v1.8.0: Refactored hooks to Perl modules, extracted addons to their own hook scripts
- v1.7.0: Updated to use Jammy stemcells