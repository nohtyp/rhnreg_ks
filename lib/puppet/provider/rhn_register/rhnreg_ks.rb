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

    return params
  end

  def register
    cmd = build_parameters
    rhnreg_ks(*cmd)
  end

  def create
    Puppet.debug('Server is not registered, Registering server now.')
    register
  end

  def check_server(mysystem, mylogin, mypassword, myurl)
    @MySystem = mysystem.to_s
    @Satellite_Login = mylogin.to_s
    @Satellite_Password = mypassword.to_s
    @Satellite_Url = URI(myurl.to_s)
    @Satellite_Url.path = '/rpc/api'

    @client = XMLRPC::Client.new2("#{@Satellite_Url}")

    # disable check of ssl cert
    @client.instance_variable_get(:@http).verify_mode = OpenSSL::SSL::VERIFY_NONE
     begin
      @key = @client.call('auth.login', @Satellite_Login, @Satellite_Password)
      rescue
       fail("Failed to contact the server #{@resource[:server_url]}")
     end
       serverList = @client.call('system.listSystems', @key)
       serverList.each do |x|
         if x['name'] == "#{@MySystem}"
           return true
         else
           next
         end
       end
      Puppet.debug("Server #{@MySystem} not found")
      return false
  end

  def destroy_server(mysystem, mylogin, mypassword, myurl)
    @MySystem = mysystem.to_s
    @Satellite_Login = mylogin.to_s
    @Satellite_Password = mypassword.to_s
    @Satellite_Url = URI(myurl.to_s)
    @Satellite_Url.path = '/rpc/api'

      def delete_server(myserver, myserverid)
        Puppet.debug("This script has deleted server #{myserver} with id: #{myserverid} from #{@Satellite_Url.host}")
        @client.call('system.deleteSystems', @key, myserverid)
      end

    @client = XMLRPC::Client.new2("#{@Satellite_Url}")

    # disable check of ssl cert
    @client.instance_variable_get(:@http).verify_mode = OpenSSL::SSL::VERIFY_NONE

    begin
    @key = @client.call('auth.login', @Satellite_Login, @Satellite_Password)
    rescue
      fail("Failed to contact the server #{@resource[:server_url]}")
    end
      serverList = @client.call('system.listSystems', @key)
      serverList.each do |x|
        if x['name'] == "#{@MySystem}"
          Puppet.debug("Destroying server #{@MySystem} from #{@Satellite_Url}")
          delete_server(x['name'], x['id'])
        else
          next
        end
      end
    FileUtils.rm_f("#{@sFILE}")
  end

  def destroy
    if ! @resource[:profile_name].nil?
      destroy_server(@resource[:profile_name], @resource[:username], @resource[:password], @resource[:server_url])
    else
      destroy_server(@resource[:name], @resource[:username], @resource[:password], @resource[:server_url])
    end
  end

  def exists?
    @sFILE = '/etc/sysconfig/rhn/systemid'
      if File.exist?("#{@sFILE}") && File.open("#{@sFILE}").grep(/#{@resource[:name]}/).any? && File.open("#{@sFILE}").grep(/#{@resource[:profile_name]}/).any?
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
