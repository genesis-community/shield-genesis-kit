package Genesis::Hook::PostDeploy::Shield;

use v5.20;
use warnings; # Genesis min perl version is 5.20
use Genesis qw/info/;
# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'./.genesis/lib'}

use parent qw(Genesis::Hook::PostDeploy);
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
      "\n#M{$ENV{GENESIS_ENVIRONMENT}} SHIELD Core deployed!\n".
      "\nFor details about the deployment, run\n".
      "\t#G{genesis info $ENV{GENESIS_ENVIRONMENT}}\n".
      "\nTo access the SHIELD Web UI, run\n".
      "\t#G{genesis do $ENV{GENESIS_ENVIRONMENT} -- open}\n".
      "\nYou may want to configure your $ENV{GENESIS_ENVIRONMENT}\n".
      "BOSH director with an add-on, via runtime configs\n".
      "\nTo generate a good starting point, run\n".
      "\t#G{genesis do $ENV{GENESIS_ENVIRONMENT} -- runtime-config}\n"
    );
  }

  return $self->done(1);
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
