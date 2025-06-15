# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
package Genesis::Hook::Info::Shield;

use v5.20;
use warnings; # Genesis supports min perl v5.20.

# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}

# Parent class inheritance
use parent qw(Genesis::Hook::Info);

# Import required functions
use Genesis qw/info/;

sub init {
  my ($class, %ops) = @_;
  my $obj = $class->SUPER::init(%ops);
  $obj->check_minimum_genesis_version('3.1.0-rc.20');
  return $obj;
}

sub perform {
  my ($self) = @_;

  my $core_name;
  if ($self->env->has_feature('ocfp')) {
    $core_name = $self->env->lookup('meta.core.name');
  } else {
    $core_name = $self->env->lookup('params.installation', 'S.H.I.E.L.D.');
  }

  info(
    "\n#B{%s}\n".  
    "endpoint information\n".  
    "\t#C{%s}\n".  
    "admin credentials\n".  
    "\tusername: #M{%s}\n".  
    "\tpassword: #G{%s}\n",
    $core_name,
    $self->exodus_data("url"),
    $self->exodus_data("admin_username"),
    $self->exodus_data("admin_password")
  );

  return $self->done();
}

1;
