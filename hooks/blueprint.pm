package Genesis::Hook::Blueprint::Shield v2.1.0;

use v5.20;
use warnings;

# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}
use parent qw(Genesis::Hook::Blueprint);

use Genesis qw/bail info/;

sub init {
	my $class = shift;
	my $obj = $class->SUPER::init(@_);
	$obj->{files} = [];
	$obj->check_minimum_genesis_version('3.1.0-rc.20');
	return $obj;
}

sub perform {
	my ($blueprint) = @_; # $blueprint is '$self'

	$blueprint->add_files(qw(
          manifests/shield.yml
          manifests/releases/shield.yml
	));

  # Feature handling
  if ($blueprint->want_feature('postgres-addon')) {
    $blueprint->add_files(qw(
      manifests/addons/postgres.yml
      manifests/releases/shield-addon-postgres.yml
    ));
  }

  if ($blueprint->want_feature('okta')) {
    $blueprint->add_files(qw(manifests/addons/okta.yml));
  }

  if ($blueprint->want_feature('secure')) {
    $blueprint->add_files(qw(manifests/addons/secure.yml));
  }

  if ($blueprint->want_feature('webdav-store')) {
    $blueprint->add_files(qw(manifests/addons/webdav-store.yml));
  }

  if ($blueprint->want_feature('oauth') || $blueprint->want_feature('oauth-provider')) {
    if ($blueprint->want_feature('oauth-provider')) {
      info("The oauth-provider feature flag is now just called 'oauth'.");
    }
    $blueprint->add_files(qw(manifests/oauth.yml));
  }

  if ($blueprint->want_feature('proxy')) {
    info(
      "\nYou no longer need to explicitly specify the 'proxy' feature.\n\t=> If you remove it, everything will still work as expected.\n"
    );
  }

  # ocfp feature overrides everything except ops files
  if ($blueprint->want_feature('ocfp')) {
    $blueprint->add_files(qw(
      ocfp/meta.yml
      ocfp/ocfp.yml
    ));
    # Add IaaS-specific files if needed
    my $iaas = $blueprint->iaas;
    $blueprint->add_files_if_exists(
            "ocfp/$iaas/base.yml"
    )
  }

  # Ubuntu resolute stemcells (opt-in; the default stays ubuntu-noble).  Added
  # after every other fragment so that it wins over the stemcell default.
  if ($blueprint->want_feature('resolute')) {
    my $env = $blueprint->env;
    my $stemcell_os = $env->lookup('params.stemcell_os', 'ubuntu-resolute');
    bail(
      "The #c{resolute} feature sets the stemcell os to ubuntu-resolute, but " .
      "the environment sets #c{params.stemcell_os} to #R{%s}.  " .
      "Remove that parameter.", $stemcell_os
    ) if $stemcell_os ne 'ubuntu-resolute';

    $blueprint->add_files('manifests/resolute.yml');
  } elsif ($blueprint->env->lookup('params.stemcell_os', 'ubuntu-noble') eq 'ubuntu-resolute') {
    bail(
      "The environment sets #c{params.stemcell_os} to ubuntu-resolute " .
      "without the #c{resolute} feature.  Enable the feature and remove " .
      "that parameter."
    );
  }

  # Add any ops files
  for my $feature ($blueprint->features) {
    if (!grep {$_ eq $feature} qw(ocfp oauth oauth-provider proxy postgres-addon secure okta webdav-store resolute)) {
      my $ops_file = $blueprint->env->path("ops/$feature.yml");
      if (-f $ops_file) {
          $blueprint->add_files($ops_file);
      } else {
        bail("Unsupported feature: %s", $feature);
      }
    }
  }

  return $blueprint->done(1);
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
