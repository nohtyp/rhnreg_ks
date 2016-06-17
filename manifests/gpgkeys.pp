class rhnreg_ks::gpgkeys inherits rhnreg_ks {
  
  file { 'RHN_REG GPG Directory':
    path    => '/root/rhnreg_gpgkeys',
    ensure  => directory,
  }

  file { '/root/rhnreg_gpgkeys/RPM-GPG-KEY-spacewalk-2015':
      ensure  => file,
      require => File['RHN_REG GPG Directory'],
      source  => [
       'puppet:///modules/rhnreg_ks/RPM-GPG-KEY-spacewalk-2015',
        ]
    }

  exec { 'import rhnreg gpgkeys':
      path       =>  '/bin:/usr/bin',
      command    => "rpm --import /root/rhnreg_gpgkeys/RPM-GPG-KEY-spacewalk-2015",
      require    => [ File['/root/rhnreg_gpgkeys/RPM-GPG-KEY-spacewalk-2015'],
                    ],
      #unless     =>  [ 'test -f /root/rhnreg_gpgkeys/RPM-GPG-KEY-spacewalk-2015',
      #               ],
  }
}
