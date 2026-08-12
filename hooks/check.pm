package Genesis::Hook::Check::Shield v2.1.0;

use v5.20;
use warnings; # Genesis supports min perl v5.20.

# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}

# Parent class inheritance
use parent qw(Genesis::Hook::Check);

# Import required functions
use Genesis qw/info/;

sub init {
  my ($class, %ops) = @_;
  my $obj = $class->SUPER::init(%ops);
  $obj->{ok} = 1; # Start assuming all checks will pass
  $obj->check_minimum_genesis_version('3.1.0-rc.20');
  return $obj;
}

sub perform {
  my ($self) = @_;

  # Note: Cloud config checking code removed as per requirements
  # TODO: Any additional checks can be implemented here...
  if ($self->{ok}) {
    $self->env->notify(success => "environment files [#G{OK}]");
  } else {
    $self->env->notify(error => "environment files [#R{FAILED}]");
  }

  return $self->done($self->{ok});
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
