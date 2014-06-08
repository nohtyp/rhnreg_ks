class rhnreg_ks (
  $serverurl = 'satellite serverurl',
  $username = 'root',
  $password = 'password',
  $server = $::hostname,
  $profilename = $::fqdn,
  $path = '/etc/sysconfig/rhn/up2date',
  $myup2date = 'serverURL=https://*',
  $replaceurl = 'serverURL=https://vasat.promnetwork.com/XMLRPC',
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

  file_line { $::fqdn:
    path    => $path,
    match   => $myup2date,
    line    => $replaceurl,
    require => Rhn_register["$server"],
  }

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

