class rhnreg_ks::service inherits rhnreg_ks {

 service { 'rhnsd':
    ensure  => 'running',
    require => Package['rhnsd'],
  }
}
