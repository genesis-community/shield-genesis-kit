package Genesis::Hook::Addon::Shield::RuntimeConfig v2.1.0;

use v5.20;
use warnings; # Genesis min perl version is 5.20

# Only needed for development
BEGIN {push @INC, $ENV{GENESIS_LIB} ? $ENV{GENESIS_LIB} : $ENV{HOME}.'/.genesis/lib'}

use Genesis qw/bail info run/;
use Genesis::State qw/envset/;
use Genesis::UI qw/prompt_for_boolean/;

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
  "  #y{--vaultify}        Keep secrets as vault operations for better security.\n".
  "  #y{--yes}, #y{-y}         Upload the runtime-config without asking first.\n".
  "                    Use this in a pipeline, where nobody can see the prompt\n".
  "                    or answer it.  Setting the #y{BOSH_NON_INTERACTIVE}\n".
  "                    environment variable does the same thing.\n".
  "  #y{--no-upload}       Print the runtime-config and stop, without uploading it\n".
  "                    and without asking.\n";
}

sub perform {
  my ($self) = @_;
  my $env = $self->env;

  # Parse options
  my $options = $self->parse_options([
    'vaultify',
    'yes|y',
    'no-upload',
  ]);

  my $vaultify = $options->{vaultify} ? 1 : 0;
  my $no_upload = $options->{'no-upload'} ? 1 : 0;
  # Assume yes when asked to, and when the caller has already told BOSH not to
  # ask, because a prompt in a pipeline is invisible and cannot be answered.
  my $assume_yes = ($options->{yes} || envset('BOSH_NON_INTERACTIVE')) ? 1 : 0;

  bail(
    "\n#R{[ERROR]} --yes and --no-upload contradict each other.\n".
    "\tPick one, or neither to be asked.\n"
  ) if $assume_yes && $no_upload;

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
    $config .= $self->indented_secret("certs/ca:certificate") . "\n";
  }

  $config .= "\n          agent:\n";

  if ($vaultify) {
    $config .= "            key: (( vault meta.vault \"agent:public\" ))\n";
  } else {
    $config .= "            key: |\n";
    $config .= $self->indented_secret("agent:public") . "\n";
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

  if ($no_upload) {
    info("Runtime config not uploaded.");
    return $self->done();
  }

  my $upload = $assume_yes || prompt_for_boolean(
    "Do you want to save this runtime-config as '$config_name'? [y|n]", 1
  );

  if ($upload) {
    $self->env->bosh->upload_config($config,'runtime',$config_name);
  } else {
    info("Runtime config not uploaded.");
  }
  return $self->done();
}

# indented_secret - a vault value, ready to sit under a YAML literal block
#
# The value read from vault carries a trailing newline, and a literal block that
# ends on a bare indent renders as trailing blank lines in the runtime config, so
# trim the trailing whitespace before indenting each line.
sub indented_secret {
  my ($self, $path) = @_;
  my ($value) = $self->vault->get("$ENV{GENESIS_SECRETS_BASE}$path");
  bail(
    "\n#R{[ERROR]} No value found in the vault at '#C{%s%s}'.\n".
    "\tPlease run #G{genesis check-secrets} on this environment.\n",
    $ENV{GENESIS_SECRETS_BASE}, $path
  ) unless defined($value) && $value =~ /\S/;
  $value =~ s/\s+\z//;
  $value =~ s/^/              /mg;
  return $value;
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
