# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
package Genesis::Hook::Addon::Shield::Open;

use v5.20;
use warnings; # Genesis min perl version is 5.20
use Genesis qw/bail info run/;
# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'./.genesis/lib'}

use parent qw(Genesis::Hook::Addon);
sub init {
  my $class = shift;
  my $obj = $class->SUPER::init(@_);
  $obj->check_minimum_genesis_version('3.1.0-rc.20');
  return $obj;
}

sub cmd_details {
  return
  "Open the SHIELD Web Interface in your browser (macOS & Linux only)\n";
}

sub perform {
  my ($self) = @_;
  my $env = $self->env;

  my $cmd;
  my $uname = `uname`;
  chomp($uname);

  if ($uname eq "Linux") {
    $cmd = "xdg-open";
  } elsif ($uname eq "Darwin") {
    $cmd = "open";
  } else {
    $env->notify("The 'open' addon script only works on macOS and Linux, currently.");
    return 0;
  }

  unless (`command -v $cmd 2>/dev/null`) {
    $env->notify("The 'open' addon script requires the '$cmd' command to be available.");
    return 0;
  }

  my $ip = $self->ip();
  system($cmd, "https://$ip");

  return $self->done();
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
