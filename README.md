# NOHTYP-RHNREG_KS [![Build Status](https://travis-ci.org/nohtyp/rhnreg_ks.svg?branch=master)](https://travis-ci.org/nohtyp/rhnreg_ks)

This module provides a custom puppet provider to handle RHN, SATELLITE 
and SPACEWALK server registering/un-registering. Also, module handles
`VMware` cloning.

## License

Read Licence file for more information.

## Requirements
* puppet-boolean [on GitHub](https://github.com/adrienthebo/puppet-boolean)

## Inspired by

* Gaël Chamoulaud (gchamoul at redhat dot com)
* [Strider/rhnreg_ks](https://forge.puppetlabs.com/strider/rhnreg_ks)

## Type and Provider

The module adds the following new types:

* `rhn_register` for managing Red Hat Network Registering

### Parameters

- **activationkeys**: The activation key to use when registering the system
- **ensure**: Valid values are `present`, `absent`. Default value is `present`.
- **force**: No need to use this option, unless want to register system every run. Default value `false`.
- **hardware**: Whether or not the hardware information should be probed. Default value is `true`.
- **packages**: Whether or not packages information should be probed. Default value is `true`.
- **password**: The password to use when registering the system (required)
- **profile_name**: The name the system should use in RHN or Satellite(if not set defaults to `hostname`)
- **proxy**: If needed, specify the HTTP Proxy
- **proxy_password**: Specify a password to use with an authenticated http proxy
- **proxy_user**: Specify a username to use with an authenticated http proxy
- **rhnsd**: Whether or not rhnsd should be started after registering. Default value is `true`.
- **server_url**: Specify a url to use as a server (required)
- **ssl_ca_cert**: Specify a file to use as the ssl CA cert
- **username**: The username to use when registering the system (required)
- **virtinfo**: Whether or not virtualiztion information should be uploaded. Default value is `true`.

### Example

Registering Clients to RHN Server with activation keys:

<pre>
rhn_register { 'server.example.com':
  activationkeys => '2-rhel6-key',
  ensure         => 'present',
  username       => 'myusername',
  password       => 'mypassword',
  server_url     => 'https://xmlrpc.rhn.redhat.com/XMLRPC',
  ssl_ca_cert    => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
}
</pre>

Un-register Clients RHN Server with activation keys:

<pre>
rhn_register { 'server.example.com':
  activationkeys => '2-rhel6-key',
  ensure         => 'absent',
  username       => 'myusername',
  password       => 'mypassword',
  server_url     => 'https://xmlrpc.rhn.redhat.com/XMLRPC',
  ssl_ca_cert    => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
}
</pre>


##Hiera

This module works with hiera all options are available through variables:

`examples`

rhn_register::activationkeys: '2-rhel6-key' would set the activationkey to join the spacewalk server
rhn_register::changeover: true would change the system over to the new spacewalk server
rhn_register::username: myusername would be the username you want to verify settings in spacewalk

## Installing

In your puppet modules directory:

  git clone https://github.com/nohtyp/rhnreg_ks.git 

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

### Notes
`username` and `password` are required to connect to the RHN, SATELLITE, SPACEWALK server to check if server previously exists.

In a normal configuration username/password and activationkeys could not be used together, but since this module will support
RHN, SATELLITE, SPACEWALK register and un-register by being able to log into the system using the api it needs username/password.

To see the output of what the module is doing, run with the --debug option.

### Updates

`changeover` was added to module to help changing spacewalk servers and domains without going to every server to re-register.  Also,
there were packages that are added to help the deployment of this module seamlessly into your environment.  This module does require installing rubygems and requires the build of gems.

## Issues

Please file any issues or suggestions on [on GitHub](https://github.com/nohtyp/rhnreg_ks/issues)
