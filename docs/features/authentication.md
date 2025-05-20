# Authentication Options

SHIELD Genesis Kit supports multiple authentication methods to provide flexibility and security for different deployment scenarios.

## Built-in Authentication

By default, SHIELD uses a built-in authentication mechanism with a static admin username and password.

### Securing Built-in Authentication

To improve security for the built-in authentication:

1. Enable the `secure` feature to have a secure password automatically generated
2. Optionally set a custom admin username

Example:

```yaml
kit:
  features:
    - secure
    
params:
  admin_username: shield-admin  # Optional, defaults to 'admin'
```

## OAuth2 Authentication

SHIELD can integrate with OAuth2 providers to leverage existing identity systems. To enable OAuth2 authentication, use the `oauth` feature.

### GitHub

GitHub can be used as an authentication provider, allowing teams to use their GitHub identities for SHIELD access.

Example:

```yaml
kit:
  features:
    - oauth
    
params:
  authentication:
    - name: Github
      identifier: github
      backend: github
      properties:
        client_id: <client-id>
        client_secret: <client-secret>
        mapping:
          - github: starkandwayne  # GitHub org name
            tenant: starkandwayne  # SHIELD tenant name
            rights:
              - team: Owners       # GitHub team name
                role: admin        # SHIELD role name
              - team: Engineering  # First match wins
                role: engineer
              - role: operator     # Default match
```

### Cloud Foundry UAA

UAA (User Account and Authentication) from Cloud Foundry can be used as an authentication provider, allowing for integration with existing CF deployments.

Example:

```yaml
kit:
  features:
    - oauth
    
params:
  authentication:
    - name: UAA
      identifier: uaa1
      backend: uaa
      properties:
        client_id: <client-id>
        client_secret: <client-secret>
        uaa_endpoint: https://uaa.example.com:8443
        skip_verify_tls: true
        mapping:
          - tenant: UAA          # SHIELD tenant name
            rights:
              - scim: uaa.admin  # UAA scim right
                role: admin      # SHIELD role
              - scim: cloud_controller.write
                role: engineer
              - role: operator   # Default match
```

### Okta

Okta can be used as an authentication provider for enterprise environments. To enable Okta authentication, use both the `oauth` and `okta` features.

Example:

```yaml
kit:
  features:
    - oauth
    - okta
```

Required vault credentials:

```
$ genesis do my-shield-env -- vault put secret/path/to/okta client_id=... client_secret=... domain=... auth_server=...
```

## Multiple Authentication Providers

SHIELD can be configured with multiple authentication providers simultaneously. To do this, add multiple entries to the `authentication` parameter.

Example:

```yaml
params:
  authentication:
    - name: Github
      identifier: github
      backend: github
      properties:
        # Github configuration
        
    - name: UAA
      identifier: uaa1
      backend: uaa
      properties:
        # UAA configuration
```

## Role Mapping

Authentication providers map external identities to SHIELD roles:

- **admin**: Full administrative access to SHIELD
- **engineer**: Can configure tenants, targets, stores, and jobs, but cannot manage users
- **operator**: Can run jobs and restore data, but cannot modify configuration

## System Tenant

The "SYSTEM" tenant is special in SHIELD - users with roles in this tenant can manage SHIELD itself. Be careful about which users get admin access to the SYSTEM tenant.