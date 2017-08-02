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

- **github-oauth** - Sets up OAuth2 using `github.com` as the OAuth Provider.
  This allows you to give multiple people access to SHIELD, with access based on
  GitHub org membership.
- **cf-oauth** - Sets up OAuth2 using a user-supplied [UAA][4] as the OAuth Provider.
  This allows you to give multiple people access to SHIELD with access based on
  their group membership inside the UAA.
- **http-auth** - Sets up HTTP Basic Authentication and a single user/password
  to be used by SHIELD for authenticating.

Params
------

#### Base Params

There is one required params for SHIELD when deployed with no subkits enabled.

- **parms.shield_static_ip** - Choose a static IP from the network in your Cloud Config.
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

#### cf-oauth Params

Required Params:

- **UAA Client ID** - In order to validate OAuth attempts, SHIELD needs to authenticate
  to the UAA. This is the client ID of the UAA client that SHIELD will use to communicate
  with the UAA. It will need the `openid,scim.real` scopes. This data will be stored in Vault.
- **UAA Client Secret** - This is the UAA client secret for the above client. This data
  stored in Vault.
- **params.authz_allowed_groups** - A list of UAA groups for authorizing SHIELD users.
  If a user authenticating to SHIELD is in at least one of the defined groups, they are
  allowed into shield.

#### github-oauth Params

Required params:

- **GitHub OAuth Client ID** - In order to validate OAuth attempts, SHIELD needs to authenticate
  to GitHub. When you configure an OAuth integration with GitHub, this will be the `client_id`.
  See https://developer.github.com/v3/oauth/ for more info.
- **GitHub OAuth Client Secret** - This is the GitHub `client_secret` for the above OAuth client.
  This data stored in Vault.
- **params.authz_allowed_groups** - A list of GitHub Organizations for authorizing SHIELD users.
  If a user authenticating to SHIELD is in at least one of the defined orgs, they are
  allowed into shield.

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
