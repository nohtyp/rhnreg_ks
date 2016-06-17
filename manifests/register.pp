class rhnreg_ks::register inherits rhnreg_ks {

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
}
