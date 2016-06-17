class rhnreg_ks::changeover inherits rhnreg_ks {

  exec { 'rhnreg_ks':
    path    => '/usr/sbin/',
    command => "rhnreg_ks --serverUrl=$serverurl --activationkey=$activationkeys --force",
    unless  => "/bin/grep $serverurl $path",
  }
}

