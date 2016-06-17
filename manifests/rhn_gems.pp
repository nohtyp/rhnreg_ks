class rhnreg_ks::rhn_gems inherits rhnreg_ks {

  package { 'rubygems':
    ensure => 'installed',
  }

  package { $rhn_rubygems:
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['rubygems'],
  }
}
