package Genesis::Hook::New::Shield v2.0.0;

use v5.20;
use warnings; # Genesis supports min perl v5.20.

BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}
use parent qw(Genesis::Hook);

use Genesis qw/run/;
use Genesis::UI qw(prompt_for_boolean);

sub init {
  my $class = shift;
  my $obj = $class->SUPER::init(@_);
  $obj->{features} = [];
  return $obj;
}

sub perform {
  my ($self) = @_;
  my $env = $self->env;

  # Get IP address
  my $ip;
  $self->env->prompt_for('ip', 'line', 'What IP address would you like to deploy SHIELD on?', \$ip);

  # Get external domain
  my $external_domain;
  $self->env->prompt_for('external_domain', 'line',
    'What domain name would you like to use? (leave blank to just use IP)',
    '--default', '', \$external_domain);

  # OAuth configuration
  my $isoauth;
  $self->env->prompt_for('isoauth', 'boolean', '-i', '--default', 'false',
    'Would you like to authenticate against an OAuth2 endpoint (Github / UAA)? [y|N]',
    \$isoauth);

  # Secure configuration
  my $secure;
  $self->env->prompt_for('secure', 'boolean', '-i', '--default', 'true',
    'Would you like to secure the admin user with a generated password and optional username? [Y|n]',
    \$secure);

  my $username = 'admin';
  if ($secure) {
    $self->env->prompt_for('username', 'line', '-i', '--default', $username,
      'Admin username:', \$username);
  }

  # Create environment file
  my $env_file = "$ENV{GENESIS_ROOT}/$ENV{GENESIS_ENVIRONMENT}.yml";
  open my $fh, ">", $env_file or die "Cannot open $env_file for writing: $!";

  print $fh "---\n";
  print $fh "kit:\n";
  print $fh "  name:    $ENV{GENESIS_KIT_NAME}\n";
  print $fh "  version: $ENV{GENESIS_KIT_VERSION}\n";

  if ($isoauth || $secure) {
    print $fh "  features:\n";
    print $fh "    - oauth\n" if $isoauth;
    print $fh "    - secure\n" if $secure;
  } else {
    print $fh "  features: []\n";
  }
  print $fh "\n";

  # Generate and add the genesis_config_block
  my $out = $self->env->genesis_config_block();
  print $fh $out;

  print $fh "params:\n";
  print $fh "  shield_static_ip: $ip\n";
  if ($external_domain) {
    print $fh "  external_domain: $external_domain\n";
  }
  if ($username ne "admin") {
    print $fh "  admin_username: $username\n";
  }

  close $fh;

  # Offer environment editor
  $self->env->offer_environment_editor();

  return $self->done();
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
