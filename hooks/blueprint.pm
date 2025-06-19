package Genesis::Hook::Blueprint::Shield;

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
  }

  # Add any ops files
  for my $feature ($blueprint->features) {
    if (!grep {$_ eq $feature} qw(ocfp oauth oauth-provider proxy postgres-addon secure okta)) {
      my $ops_file = "ops/$feature.yml";
      if (-f $blueprint->env->path($ops_file)) {
        if ($blueprint->want_feature('ocfp')) {
          # For OCFP, we need to handle ops files differently
          $blueprint->add_opsfile($ops_file);
        } else {
          $blueprint->add_files($ops_file);
        }
      } else {
        bail("Unsupported feature: %s", $feature);
      }
    }
  }

  return $blueprint->done(1);
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
