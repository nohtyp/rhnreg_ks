class rhnreg_ks::exec inherits rhnreg_ks {

  exec { 'rhn-actions-control':
    path    => '/usr/bin/',
    command => 'rhn-actions-control --enable-all',
    onlyif  => 'rhn-actions-control --report | /bin/grep disabled',
    require => Package['rhncfg-actions'],
  }
}
