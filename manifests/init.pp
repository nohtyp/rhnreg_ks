# ==Class: rhnreg_ks
# Parameters
# activationkeys: The activation key to use when registering the system
# ensure: Valid values are `present`, `absent`. Default value is `present`.
# force: No need to use this option, unless want to register system every run. Default value `false`.
# hardware: Whether or not the hardware information should be probed. Default value is `true`.
# packages: Whether or not packages information should be probed. Default value is `true`.
# password: The password to use when registering the system (required)
# profile_name: The name the system should use in RHN or Satellite(if not set defaults to `hostname`)
# proxy: If needed, specify the HTTP Proxy
# proxy_password: Specify a password to use with an authenticated http proxy
# proxy_user: Specify a username to use with an authenticated http proxy
# rhnsd: Whether or not rhnsd should be started after registering. Default value is `true`.
# server_url: Specify a url to use as a server (required)
# ssl_ca_cert: Specify a file to use as the ssl CA cert
# username: The username to use when registering the system (required)
# virtinfo: Whether or not virtualiztion information should be uploaded. Default value is `true`.
#

class rhnreg_ks (
  $serverurl = 'satellite serverurl',
  $username = 'root',
  $password = 'password',
  $server = $::hostname,
  $profilename = $::fqdn,
  $path = '/etc/sysconfig/rhn/up2date',
  # $myup2date = 'serverURL=https://*',
  # $replaceurl = 'serverURL=https://<serverURL with proxyURL>/XMLRPC',
  $presentorabsent = 'present',
  $cacert = '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
  $useforce = false,
  $activationkeys = $rhnreg_ks::params::activationkeys
) inherits rhnreg_ks::params {

  if $activationkeys == 'undef' {
    fail('No Activation key specified found for system')
  }

  rhn_register { $server:
  ensure         => $presentorabsent,
  activationkeys => $activationkeys,
  username       => $username,
  password       => $password,
  profile_name   => $profilename,
  server_url     => $serverurl,
  ssl_ca_cert    => $cacert,
  force          => $useforce,
  }

  # file_line { $::fqdn:
  #  path    => $path,
  #  match   => $myup2date,
  #  line    => $replaceurl,
  #  require => Rhn_register["$server"],
  #}

  package {'rhn-client-tools':
    ensure => 'installed',
  }

  package {'rhncfg-actions':
    ensure => 'installed',
  }

  package {'rhnsd':
    ensure => 'installed',
  }

  service {'rhnsd':
    ensure  => 'running',
    require => Package['rhnsd'],
  }

  exec { 'rhn-actions-control':
    path    => '/usr/bin/',
    command => 'rhn-actions-control --enable-all',
    onlyif  => 'rhn-actions-control --report | /bin/grep disabled',
    require => Package['rhncfg-actions'],
  }
}

