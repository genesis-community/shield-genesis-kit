# Release Changes

* Bumped SHIELD to 8.2.1

# Params

* `params.external_domain` is now a thing - it allows you to specify the DNS
	name for your server if you've set one up. If present, this currently causes
	the check script to validate the served certificates against this domain
	instead of the static IP. This allows you to deploy an actual signed
	certificate for an actual domain without Genesis getting all mad.

# Software Components	

| Name | Version | Release Notes |	
| --- | --- | --- |	
| SHIELD | 8.2.1 | [Release Notes][v8.2.1] |

[v8.2.1]: https://github.com/starkandwayne/shield/releases/tag/v8.2.1
