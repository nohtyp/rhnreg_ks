# ==Class rhnreg_ks::params

class rhnreg_ks::params {

$serverurl          = 'https://serverurl/XMLRPC'
$username           = 'username'
$password           = 'password'
$server             = $::hostname
$profilename        = "$::fqdn"
$path               = '/etc/sysconfig/rhn/up2date'
# $myup2date        = 'serverURL=https://*'
# $replaceurl       = 'serverURL=https://<serverURL with proxyURL>/XMLRPC'
$presentorabsent    = 'present'
$cacert             = '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT'
$sslcert            = 'RHN-ORG-TRUSTED-SSL-CERT'
$useforce           = false
#$activationkeys     = $rhnreg_ks::params::activationkeys
$rhnreg_packages    = [ 'rhn-client-tools', 'rhnsd', 'rhncfg-actions', 'rhn-setup', 'ruby-devel', 'gcc', 'libxml2-devel' ]
$rhn_rubygems       = [ 'libxml-ruby' ]
$changeover         = false

  case $::operatingsystemmajrelease {
    #5: {
    #  $activationkeys = '2-rhel5-key'
    #}
    6: {
      $activationkeys = '1-centos6'
    }
    7: {
      $activationkeys = '1-centos7'
    }
    default: {
      $activationkeys = '1-centos7' 
    }
  }
}
