# ==Class: rhnreg_ks
# Parameters
# activationkeys: The activation key to use when registering the system
# ensure: Valid values are `present`, `absent`. Default value is `present`.
# force: No need to use this option, unless want to register system every run. Default value `false`.
# hardware: Whether or not the hardware information should be probed. Default value is `true`.
# packages: Whether or not packages information should be probed. Default value is `true`.
# password: The password to use when registering the system (required)
# profile_name: The name the system should use in RHN or Satellite(if not set defaults to `hostname`)
# proxy: If needed, specify the HTTP Proxy
# proxy_password: Specify a password to use with an authenticated http proxy
# proxy_user: Specify a username to use with an authenticated http proxy
# rhnsd: Whether or not rhnsd should be started after registering. Default value is `true`.
# server_url: Specify a url to use as a server (required)
# ssl_ca_cert: Specify a file to use as the ssl CA cert
# username: The username to use when registering the system (required)
# virtinfo: Whether or not virtualiztion information should be uploaded. Default value is `true`.
#

class rhnreg_ks (
$serverurl          = $rhnreg_ks::params::serverurl,
$username           = $rhnreg_ks::params::username,
$password           = $rhnreg_ks::params::password,
$server             = $rhnreg_ks::params::hostname,
$profilename        = $rhnreg_ks::params::fqdn,
$path               = $rhnreg_ks::params::path,
# $myup2date        = 'serverURL=https://*',
# $replaceurl       = 'serverURL=https://<serverURL with proxyURL>/XMLRPC',
$presentorabsent    = $rhnreg_ks::params::presentorabsent,
$cacert             = $rhnreg_ks::params::cacert,
$useforce           = $rhnreg_ks::params::useforce,
$activationkeys     = $rhnreg_ks::params::activationkeys,
$changeover         = $rhnreg_ks::params::changeover
) inherits rhnreg_ks::params {

if $changeover == true {
  anchor { 'rhnreg_ks::begin': } ->
    class {'::rhnreg_ks::file':} ->
    class {'::rhnreg_ks::gpgkeys':} ->
    class {'::rhnreg_ks::changeover':} ->
    class {'::rhnreg_ks::install':} ->
    class {'::rhnreg_ks::rhn_gems':}  ->
    class {'::rhnreg_ks::service':} ->
    class {'::rhnreg_ks::register':}
    class {'::rhnreg_ks::exec':}  ->
  anchor { 'rhnreg_ks::end': }
 }
else {
  anchor { 'rhnreg_ks::begin': } ->
    class {'::rhnreg_ks::file':} ->
    class {'::rhnreg_ks::gpgkeys':} ->
    class {'::rhnreg_ks::install':} ->
    class {'::rhnreg_ks::rhn_gems':}  ->
    class {'::rhnreg_ks::service':} ->
    class {'::rhnreg_ks::register':}
    class {'::rhnreg_ks::exec':}  ->
  anchor { 'rhnreg_ks::end': }
 }
}
