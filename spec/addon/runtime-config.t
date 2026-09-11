#!/usr/bin/perl
# Exercises the runtime-config addon hook without a director or a vault.
#
# The hook is loaded for real and its collaborators are replaced with stubs, so
# the test covers the rendered YAML and the option handling rather than the
# plumbing underneath them.

use v5.20;
use strict;
use warnings;
use Test::More;
use File::Basename qw/dirname/;
use File::Spec;

my $kit_dir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', '..'));
my $hook = File::Spec->catfile($kit_dir, 'hooks', 'addon-runtime-config~rc.pm');

my $genesis_lib = $ENV{GENESIS_LIB} || File::Spec->catdir($ENV{HOME}, '.genesis', 'lib');
plan skip_all => "Genesis libraries not found at $genesis_lib; set GENESIS_LIB"
  unless -f File::Spec->catfile($genesis_lib, 'Genesis.pm');

unshift @INC, $genesis_lib;
$ENV{GENESIS_SECRETS_BASE} = 'secret/lab/shield/';
$ENV{GENESIS_LIB} = $genesis_lib;

my $CA  = "-----BEGIN CERTIFICATE-----\nMIIBfake\n-----END CERTIFICATE-----\n";
my $KEY = "ssh-rsa AAAAB3NzaC1yc2EAAAA shield-agent\n\n";

# ---- stubs ----------------------------------------------------------------

package FakeVault;
sub new { bless {}, shift }
sub get {
  my ($self, $path) = @_;
  return ($CA)  if $path =~ m{certs/ca:certificate$};
  return ($KEY) if $path =~ m{agent:public$};
  return (undef);
}

package FakeBosh;
our @UPLOADS;
sub new { bless {}, shift }
sub upload_config {
  my ($self, $config, $type, $name) = @_;
  push @UPLOADS, {config => $config, type => $type, name => $name};
  return 1;
}

package FakeEnv;
sub new    { bless {}, shift }
sub name   { 'lab' }
sub type   { 'shield' }
sub bosh   { FakeBosh->new }
sub lookup { '' }

package main;

require $hook;
my $P = 'Genesis::Hook::Addon::Shield::RuntimeConfig';
{
  no strict 'refs';
  no warnings 'redefine';
  *{"${P}::env"}                 = sub { FakeEnv->new };
  *{"${P}::vault"}               = sub { FakeVault->new };
  *{"${P}::was_deployed"}        = sub { 1 };
  *{"${P}::shield_version"}      = sub { '8.8.2' };
  *{"${P}::shield_url"}          = sub { 'https://10.10.10.10' };
  *{"${P}::done"}                = sub { 1 };
  *{"${P}::label"}               = sub { 'runtime-config' };
  # The hook imported this name at compile time, so the stub has to replace the
  # hook package's copy rather than the one in Genesis::UI.
  *{"${P}::prompt_for_boolean"}  = sub { die "PROMPTED\n" };
}

# run_addon - drive the hook with the given arguments
#
# Returns the error the hook died with, or undef, along with every config the
# fake director was asked to upload.
sub run_addon {
  local @FakeBosh::UPLOADS = ();
  my $self = bless {args => [@_]}, $P;
  my $err;
  eval { $self->perform; 1 } or $err = $@;
  return ($err, [@FakeBosh::UPLOADS]);
}

# ---- the cases ------------------------------------------------------------

subtest '--yes uploads without asking' => sub {
  my ($err, $uploads) = run_addon('--yes');
  is($err, undef, 'the addon ran without dying');
  is(scalar @$uploads, 1, 'it uploaded one config');
  is($uploads->[0]{type}, 'runtime', 'it uploaded a runtime config');
  is($uploads->[0]{name}, 'lab.shield.agent', 'it named the config after the env');
};

subtest 'literal blocks carry no trailing blank lines' => sub {
  my (undef, $uploads) = run_addon('--yes');
  my $config = $uploads->[0]{config};
  like($config, qr/ca: \|\n\s+-----BEGIN CERTIFICATE-----/, 'the CA sits in a literal block');
  like($config, qr/key: \|\n\s+ssh-rsa /, 'the agent key sits in a literal block');
  unlike($config, qr/-----END CERTIFICATE-----\n\s*\n\s*\n/, 'no blank run after the CA');
  unlike($config, qr/shield-agent\n\s*\n\s*\n/, 'no blank run after the agent key');
  unlike($config, qr/^[ \t]+$/m, 'no line of nothing but indentation');
};

subtest '-y is the short form of --yes' => sub {
  my ($err, $uploads) = run_addon('-y');
  is($err, undef, 'the addon ran without dying');
  is(scalar @$uploads, 1, 'it uploaded one config');
};

subtest 'BOSH_NON_INTERACTIVE stands in for --yes' => sub {
  local $ENV{BOSH_NON_INTERACTIVE} = 'true';
  my ($err, $uploads) = run_addon();
  is($err, undef, 'the addon ran without dying');
  is(scalar @$uploads, 1, 'it uploaded one config');
};

subtest '--no-upload prints and stops' => sub {
  my ($err, $uploads) = run_addon('--no-upload');
  is($err, undef, 'the addon ran without dying');
  is(scalar @$uploads, 0, 'it uploaded nothing');
};

subtest 'with no flags it still asks' => sub {
  my ($err, $uploads) = run_addon();
  like($err, qr/PROMPTED/, 'it reached the prompt');
  is(scalar @$uploads, 0, 'it uploaded nothing');
};

subtest '--yes and --no-upload contradict each other' => sub {
  my ($err, $uploads) = run_addon('--yes', '--no-upload');
  ok($err, 'the addon refused the pair');
  unlike($err, qr/PROMPTED/, 'it refused before reaching the prompt');
  is(scalar @$uploads, 0, 'it uploaded nothing');
};

subtest '--vaultify keeps the secrets as vault operators' => sub {
  my ($err, $uploads) = run_addon('--vaultify', '--yes');
  is($err, undef, 'the addon ran without dying');
  my $config = $uploads->[0]{config};
  like($config, qr/\Qca: (( vault meta.vault "certs\/ca:certificate" ))\E/, 'the CA is an operator');
  like($config, qr/\Qkey: (( vault meta.vault "agent:public" ))\E/, 'the agent key is an operator');
  unlike($config, qr/BEGIN CERTIFICATE/, 'no literal certificate leaked into the config');
};

done_testing();
