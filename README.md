SHIELD Genesis Kit
==================

This is a Genesis Kit for the [SHIELD Data Protection System][1],
from [Stark & Wayne][2]. When using [genesis][3] to deploy this kit,
you will get a fully-functional SHIELD deployment for backing up + restoring
your data services.

Quick Start
-----------

To use it, you don't even need to clone this repository!  Just run
the following (using Genesis v2):

```
# create a shield-deployments repo using the latest version of the SHIELD kit
genesis init --kit shield

# create a shield-deployments repo using v1.0.0 of the SHIELD kit
genesis init --kit shield/1.0.0

# create a my-shield-configs repo using the latest version of the SHIELD kit
genesis init --kit shield -d my-shield-configs
```

Once created, refer to the deployment repo's README for information on creating
new environments + deploying them.

Subkits
-------

#### Authentication Backends

When deploying your SHIELD, this kit provides three options for configuring
how users authenticate to SHIELD. One of these three must be specified

- **oauth-provider** - Sets up OAuth2 using Github or UAA.
  This allows you to give multiple people access to SHIELD, with access based on GitHub org/team or UAA scim rights.
- **Shield Authentication Backend** - Sets up robust user authentication
system backed by an internal local user database to be used by SHIELD for authentication.

Params
------

#### Base Params

There is one required params for SHIELD when deployed with no subkits enabled.

- **params.shield_static_ip** - Choose a static IP from the network in your Cloud Config.
  External SHIELD agents will call home to this IP.

Additionally, the following params can be overridden to customize your installation
if needed:

- **params.installation** - controls the name of the SHIELD installation, as reported
  from inside the SHIELD UI. This defaults to `S.H.I.E.L.D. Alpha`
- **params.shield_disk_pool** - used to define the persistent disk pool that the SHIELD VM will
  be given. This pool must exist in the Cloud Config of the BOSH director that deploys
  SHIELD. This defaults to `shield`.
- **params.shield_vm_type** - used to define the Cloud Config VM type that the SHIELD VM
  will be given. This VM type must exist in the Cloud config of the BOSH director that
  deploys SHIELD. This defaults to `small`, as the SHIELD daemon does not consume many
  resources.
- **params.shield_network** - used to define the Cloud Config network that the SHIELD
  VM will be located on. This network must exist in the Cloud Config of the BOSH director
  that deploys SHIELD. It defaults to `shield`, but typically this can be located
  on a shared-infrastructure network. SHIELD will need to be in a network that has SSH
  access to all of the VMs that have SHIELD agents that will be executing backup jobs.

The following (de facto) standard parameters are also supported:

- **params.stemcell_os** - What operating system to deploy on, for
  stemcell selection.  Defaults to `ubuntu-trusty`
- **params.stemcell_version** - What stemcell version to deploy.
  Defaults to `latest`, but can be set to something like
  `3468.latest` to pin your deployments to a stemcell major
  version.  If you do change this, you probably want to set
  `skip_upkeep: true` in your CI/CD pipeline definition.

#### oauth-provider Params

Required params:

- **authentication** - A shield OAuth specification for configuring auth providers that maps orgs/scim rights to teanats and roles. Note the use of the SYSTEM tenant which grants system roles instead of to a particular tenant.

Example:
```
authentication:
    - name:       Github
      identifier: github
      backend:    github
      properties:
        client_id:     <client-id>
        client_secret: <client-secret>
        mapping:
          - github: starkandwayne  # <-- github org name
            tenant: starkandwayne  # <-- shield tenant name
            rights:
              - team: Owners       # <-- github team name
                role: admin        # <-- shield role name
              - team: Engineering  #   (first match wins)
                role: engineer
              - role: operator     # = (default match)
          - github: starkandwayne
            tenant: SYSTEM
            rights:
              - team: Owners
                role: admin
    - name:       UAA
      identifier: uaa1
      backend:    uaa
      properties:
        client_id:       <client-id>
        client_secret:   <client-secret>
        uaa_endpoint:    https://uaa.shield.10.10.10.10.netip.cc:8443
        skip_verify_tls: true
        mapping:
          - tenant: UAA          # <-- shield tenant name
            rights:
              - scim: uaa.admin  # <-- uaa scim right
                role: admin      # <-- shield role
                                #   (first match wins)
              - scim: cloud_controller.write
                role: engineer
              - role: operator   # = (default match)
          - tenant: UAA Admins
            rights:
              - scim: uaa.admin
                role: admin
```

#### proxy Params

Required params:

- **http_proxy** - Specify the value to use as the HTTP proxy for all connections. For example, HTTP\_PROXY: http://proxy.mycompany.com:8080/.

- **https_proxy** - Specify the value to use as the HTTPS proxy for all connections. For example, HTTPS\_PROXY: https://proxy.mycompany.com:8080/.

- **no_proxy** - Addresses that needs to resolve on the local network and skip the proxy. For example, NO\_PROXY: localhost,.mycompany.com,192.168.0.10:80


Cloud Config
------------

By default, SHIELD uses the following VM types/networks/disk pools from your
Cloud Config. Feel free to override them in your environment, if you would
rather they use entities already existing in your Cloud Foundry:

```
params:
  shield_network:   shield
  shield_disk_pool: shield # should be at least 1GB
  shield_vm_type:   small # VMs should have at least 1 CPU, and 1GB of memory
```

[1]: https://github.com/starkandwayne/shield
[2]: https://starkandwayne.com
[3]: https://github.com/starkandwayne/genesis
[4]: https://github.com/cloudfoundry/uaa
