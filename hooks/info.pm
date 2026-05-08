package Genesis::Hook::Info::Shield v2.0.1;

use v5.20;
use warnings; # Genesis supports min perl v5.20.

# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}

# Parent class inheritance
use parent qw(Genesis::Hook);

# Import required functions
use Genesis qw/info bail run/;

# init - Initialize the hook {{{
sub init {
  my ($class, %ops) = @_;
  my $obj = $class->SUPER::init(%ops);
  $obj->check_minimum_genesis_version('3.1.0');
  return $obj;
}
# }}}

# perform - Main hook execution {{{
sub perform {
  my ($self) = @_;

  # Get Shield URL and credentials from exodus data
  my $shield_url = $self->env->exodus_lookup('url');
  bail("Shield URL not found in exodus data") unless $shield_url;

  my $username = $self->env->exodus_lookup('admin_username');
  bail("Shield username not found in exodus data") unless $username;

  my $password = $self->env->exodus_lookup('admin_password');
  bail("Shield password not found in exodus data") unless $password;

	my ($out,$rc,$err) = $self->env->bosh->execute(qw/env --tty/);

  info(
    "\n#B{Shield Information}\n\n".
    "BOSH environment:\n%s\n\n".
    "Shield Web UI:\n".
    "\t#C{%s}\n\n".
    "Credentials:\n".
    "\tusername: #M{%s}\n".
    "\tpassword: #G{%s}\n\n".
    "You can use the following addons:\n".
    "\t#G{%s do open}  # Open Shield Web UI\n".
    "\t#G{%s do runtime-config} # Print out a BOSH runtime-config\n",
    join("\n  ", '', split("\n", $out)),
    $shield_url,
    $username,
    $password,
    scalar($self->env->get_call_path_with_env()),
    scalar($self->env->get_call_path_with_env())
  );

  return $self->done(1);
}
# }}}
1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
