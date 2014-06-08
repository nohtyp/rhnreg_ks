# encoding: UTF-8
require 'xmlrpc/client'
require 'net/https'
require 'openssl'

Puppet::Type.type(:rhn_register).provide(:rhnreg_ks) do
  @doc = <<-EOS
    This provider registers a machine with an RHN, Satellite or Spacewalk
    Server. If a machine is already registered it does nothing unless the
    force parameter is set to true or the systemid file is different from
    hostname or profilename (Supports VMware cloning servers).
  EOS

  confine :osfamily => :redhat

  commands :rhnreg_ks => 'rhnreg_ks'

  def build_parameters
    params = []

    if @resource[:username].nil? && @resource[:activationkeys].nil? && @resource[:password].nil? && @resource[:server_url].nil?
      fail('Username/Password or Activationkey and ServerURL are required')
    end

    params << '--profilename' << @resource[:profile_name] unless @resource[:profile_name].nil?
    params << '--username' << @resource[:username] unless @resource[:username].nil?
    params << '--password' << @resource[:password] unless @resource[:password].nil?
    params << '--nohardware' unless @resource[:hardware]
    params << '--nopackages' unless @resource[:packages]
    params << '--novirtinfo' unless @resource[:virtinfo]
    params << '--norhnsd' unless @resource[:rhnsd]
    params << '--activationkey' <<  @resource[:activationkeys] unless @resource[:activationkeys].nil?
    params << '--proxy' <<  @resource[:proxy] unless @resource[:proxy].nil?
    params << '--proxyUser' << @resource[:proxy_user] unless @resource[:proxy_user].nil?
    params << '--proxyPassword' << @resource[:proxy_password] unless @resource[:proxy_password].nil?
    params << '--sslCACert' <<  @resource[:ssl_ca_cert] unless @resource[:ssl_ca_cert].nil?
    params << '--serverUrl' << @resource[:server_url] unless @resource[:server_url].nil?
    params << '--force' unless @resource[:force]

    params.each do |pm|
      Puppet.debug("#{pm}")
    end
    params
  end

  def register
    cmd = build_parameters
    rhnreg_ks(*cmd)
  end

  def create
    Puppet.debug('Server is not registered, Registering server now.')
    register
  end

  def delete_server(myserver, myserverid)
    Puppet.debug("This script has deleted server #{myserver} with id: #{myserverid} from #{@satellite_url.host}")
    @client.call('system.deleteSystems', @key, myserverid)
  end

  def check_server(mysystem, mylogin, mypassword, myurl)
    @mysystem = mysystem.to_s
    @satellite_login = mylogin.to_s
    @satellite_password = mypassword.to_s
    @satellite_url = URI(myurl.to_s)
    @satellite_url.path = '/rpc/api'

    @client = XMLRPC::Client.new2("#{@satellite_url}")

    # disable check of ssl cert
    @client.instance_variable_get(:@http).verify_mode = OpenSSL::SSL::VERIFY_NONE
    begin
      @key = @client.call('auth.login', @satellite_login, @satellite_password)
    rescue
      fail("Failed to contact the server #{@resource[:server_url]}")
    end
    serverlist = @client.call('system.listSystems', @key)
    serverlist.each do |x|
      if x['name'] == "#{@mysystem}"
        return true
      else
        next
      end
    end
    Puppet.debug("Server #{@mysystem} not found")
    false
  end

  def destroy_server(mysystem, mylogin, mypassword, myurl)
    @mysystem = mysystem.to_s
    @satellite_login = mylogin.to_s
    @satellite_password = mypassword.to_s
    @satellite_url = URI(myurl.to_s)
    @satellite_url.path = '/rpc/api'

    @client = XMLRPC::Client.new2("#{@satellite_url}")

    # disable check of ssl cert
    @client.instance_variable_get(:@http).verify_mode = OpenSSL::SSL::VERIFY_NONE

    begin
      @key = @client.call('auth.login', @satellite_login, @satellite_password)
    rescue
      fail("Failed to contact the server #{@resource[:server_url]}")
    end
    serverlist = @client.call('system.listSystems', @key)
    serverlist.each do |x|
      if x['name'] == "#{@mysystem}"
        Puppet.debug("Destroying server #{@mysystem} from #{@satellite_url}")
        delete_server(x['name'], x['id'])
      else
        next
      end
    end
    FileUtils.rm_f("#{@sfile}")
  end

  def destroy
    if ! @resource[:profile_name].nil?
      destroy_server(@resource[:profile_name], @resource[:username], @resource[:password], @resource[:server_url])
    else
      destroy_server(@resource[:name], @resource[:username], @resource[:password], @resource[:server_url])
    end
  end

  def exists?
    @sfile = '/etc/sysconfig/rhn/systemid'
    if File.exist?("#{@sfile}") && File.open("#{@sfile}").grep(/#{@resource[:name]}/).any? && File.open("#{@sfile}").grep(/#{@resource[:profile_name]}/).any?
      if ! @resource[:profile_name].nil?
        Puppet.debug("Checking if the server #{@resource[:profile_name]} is already registered")
        value = check_server(@resource[:profile_name], @resource[:username], @resource[:password], @resource[:server_url])
        if "#{value}" == 'true'
          if @resource[:force] == true
            destroy
            return false
          end
          return true
        else
          destroy
          return false
        end
      else
        Puppet.debug("Checking if the server #{@resource[:name]} is already registered")
        value = check_server(@resource[:name], @resource[:username], @resource[:password], @resource[:server_url])
        if "#{value}" == 'true'
          if @resource[:force] == true
            destroy
            return false
          end
          return true
        else
          destroy
          return false
        end
      end
    else
      destroy
      return false
    end
  end
end
