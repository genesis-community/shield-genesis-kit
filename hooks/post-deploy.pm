#!/usr/bin/env perl
# vim: set ts=2 sw=2 sts=2 foldmethod=marker
package Genesis::Hook::PostDeploy::Shield v4.0.0;

use strict;
use warnings;
use v5.20; # Genesis min perl version is 5.20
use Genesis qw/info/;
use parent qw(Genesis::Hook::PostDeploy);
use lib $ENV{GENESIS_LIB} // "$ENV{HOME}/.genesis/lib";

sub init {
  my ($class, %ops) = @_;
  my $self = $class->SUPER::init(%ops);
  return $self;
}

sub perform {
  my ($self) = @_;

  # Base class has deploy_successful method to check if GENESIS_DEPLOY_RC == 0
  if ($self->deploy_successful) {
    info(
      "\n#M{%1} SHIELD Core deployed!\n".
      "\nFor details about the deployment, run\n".
      "\t#G{genesis info %1}\n".
      "\nTo access the SHIELD Web UI, run\n".
      "\t#G{genesis do %1 -- open}\n".
      "\nYou may want to configure your %1\n".
      "BOSH director with an add-on, via runtime configs\n".
      "\nTo generate a good starting point, run\n".
      "\t#G{genesis do %1 -- runtime-config}\n",
      $ENV{GENESIS_ENVIRONMENT}
    );
  }

  return $self->done();
}

1;
