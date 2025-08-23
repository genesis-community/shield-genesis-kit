package Genesis::Hook::Addon::Shield::RuntimeConfig v2.0.0;

use v5.20;
use warnings; # Genesis min perl version is 5.20
use Genesis qw/bail info run/;
use Genesis::UI qw/prompt_for_boolean/;
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
  "Print out a BOSH runtime-config for setting up SHIELD agent as an add-on.\n".
  "Supports the following options:\n".
  "  #y{--vaultify}        Keep secrets as vault operations for better security.\n";
}

sub perform {
  my ($self) = @_;
  my $env = $self->env;

  # Parse options
  my $options = $self->parse_options([
    'vaultify',
  ]);

  my $vaultify = $options->{vaultify} ? 1 : 0;

  if (!$self->was_deployed()) {
    bail("",
      "\n#R{[ERROR]} No deployment found.\n".
      "\tPlease run deploy on this environment before running any addons.\n");
  }

  my $shield_version = $self->shield_version();
  my $shield_url = $self->shield_url();

  my $config = "releases:\n";
  $config .= "  - name:    shield\n";
  $config .= "    version: $shield_version\n\n";
  $config .= "meta:\n";
  $config .= "  vault: \"$ENV{GENESIS_SECRETS_BASE}\"\n\n";
  $config .= "addons:\n";
  $config .= "  - name: shield-agent\n";
  $config .= "    exclude:\n";
  $config .= "      jobs:\n";
  $config .= "      - name:    shield-agent\n";
  $config .= "        release: shield\n";
  $config .= "    jobs:\n";
  $config .= "      - name:    shield-agent\n";
  $config .= "        release: shield\n";
  $config .= "        properties:\n";
  $config .= "          shield-url: $shield_url\n";
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
  $config .= "            http_proxy:  \"" . ($self->env->lookup("params.http_proxy") || "") . "\"\n";
  $config .= "            https_proxy: \"" . ($self->env->lookup("params.https_proxy") || "") . "\"\n";
  $config .= "            no_proxy:    \"" . ($self->env->lookup("params.no_proxy") || "") . "\"\n\n";

  my $config_name = sprintf(
    "%s.%s.%s",
    $self->env->name,
    $self->env->type,
    "agent"
  );

  info($config);
  if (prompt_for_boolean(
    "Do you want to save this runtime-config as '$config_name'? [y|n]", 1
  )) {
    $self->env->bosh->upload_config($config,'runtime',$config_name);
  } else {
    info("Runtime config not uploaded.");
  }
  return $self->done();
}

sub shield_version {
  my ($self) = @_;

  if (!$self->was_deployed()) {
    bail(
      "\n#R{[ERROR]} No deployment found.".
      "\tPlease run deploy on this environment before running any addons\n"
    );
  }

  return $self->env->last_deployed_lookup("releases[name=shield].version");
}

sub shield_url {
  my ($self) = @_;
  return $self->env->exodus_lookup("url");
}


sub was_deployed {
  my ($self) = @_;
  $self->env->deployments->current_state eq "deployed";
}

1;
# vim: set ts=2 sw=2 sts=2 noet fdm=marker foldlevel=1:
