#!/usr/bin/env perl
# vim: set ts=2 sw=2 sts=2 foldmethod=marker
package Genesis::Hook::Addon::Shield::RuntimeConfig v4.0.0;

use strict;
use warnings;
use v5.20; # Genesis min perl version is 5.20
use Genesis qw/bail info run/;
use parent qw(Genesis::Hook::Addon);
use lib $ENV{GENESIS_LIB} // "$ENV{HOME}/.genesis/lib";

sub init {
  my $class = shift;
  my $obj = $class->SUPER::init(@_);
  $obj->check_minimum_genesis_version('3.1.0-rc.20');
  return $obj;
}

sub cmd_details {
  return
  "Print out a BOSH runtime-config for setting up SHIELD agent as an add-on.\n".
  "Supports the following options:\n".
  "[[  #y{--vaultify}        >>Keep secrets as vault operations for better security.\n";
}

sub perform {
  my ($self) = @_;
  my $env = $self->env;

  # Parse options
  my %options = $self->parse_options([
    'vaultify',
  ]);

  my $vaultify = $options{vaultify} ? 1 : 0;

  if (!$self->was_deployed()) {
    bail("",
      "\n#R{[ERROR]} No deployment found.\n".
      "\tPlease run deploy on this environment before running any addons.\n");
  }

  my $shield_version = $self->shield_version();
  my $ip = $self->ip();

  my $config = "releases:\n";
  $config .= "  - name:    shield\n";
  $config .= "    version: $shield_version\n\n";
  $config .= "meta:\n";
  $config .= "  vault: \"$ENV{GENESIS_SECRETS_BASE}\"\n\n";
  $config .= "addons:\n";
  $config .= "  - name: shield-agent\n";
  $config .= "    jobs:\n";
  $config .= "      - name:    shield-agent\n";
  $config .= "        release: shield\n";
  $config .= "        properties:\n";
  $config .= "          shield-url: https://$ip\n";
  $config .= "          require-shield-core: false\n\n";
  $config .= "          core:\n";

  if ($vaultify) {
    $config .= "            ca: (( vault meta.vault \"certs/ca:certificate\" ))\n";
  } else {
    $config .= "            ca: |\n";
    my ($ca_cert) = $self->vault->get("$ENV{GENESIS_SECRETS_BASE}certs/ca:certificate");
    $ca_cert =~ s/^/              /mg;
    $config .= $ca_cert . "\n";
  }

  $config .= "\n          agent:\n";

  if ($vaultify) {
    $config .= "            key: (( vault meta.vault \"agent:public\" ))\n";
  } else {
    $config .= "            key: |\n";
    my ($agent_public) = $self->vault->get("$ENV{GENESIS_SECRETS_BASE}agent:public");
    $agent_public =~ s/^/              /mg;
    $config .= $agent_public . "\n";
  }

  $config .= "\n          env:\n";
  $config .= "            http_proxy:  \"" . $self->env->lookup("params.http_proxy") . "\"\n";
  $config .= "            https_proxy: \"" . $self->env->lookup("params.https_proxy") . "\"\n";
  $config .= "            no_proxy:    \"" . $self->env->lookup("params.no_proxy") . "\"\n\n";

  info($config);
  return 1;
}

sub shield_version {
  my ($self) = @_;

  if (!$self->was_deployed()) {
    bail(
      "\n#R{[ERROR]} No deployment found.".
      "\tPlease run deploy on this environment before running any addons\n"
    );
  }

  return $self->env->lookup("--deployed", "releases[name=shield].version");
}

sub ip {
  my ($self) = @_;

  if (!$self->was_deployed()) {
    bail(
      "\n#R{[ERROR]} No deployment found.\n".
      "\tPlease run deploy on this environment before running any addons.\n"
    );
  }

  return $self->env->lookup("--deployed", "params.shield_static_ip");
}

sub was_deployed {
  my ($self) = @_;
  # TODO: There is likely a Genesis function to check if the environment was deployed
  return -f "$ENV{GENESIS_ROOT}/.genesis/manifest/$ENV{GENESIS_ENVIRONMENT}.yml";
}

1;
