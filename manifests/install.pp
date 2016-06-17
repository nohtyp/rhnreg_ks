class rhnreg_ks::install inherits rhnreg_ks {

  package { $rhnreg_packages:
    ensure => 'installed',
    #require => File[$cacert], 
  }
}
