class rhnreg_ks::file inherits rhnreg_ks {

  file { "$cacert":
      ensure   => present,
      path     => "$cacert",
      backup   => true,
      source   => "puppet:///modules/rhnreg_ks/$sslcert",
      mode     => '0644',
      owner    => 'root',
      group    => 'root',
    }
}
