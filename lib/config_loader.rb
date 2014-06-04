require 'yaml'
require 'ostruct'

require_relative 'load_profile'
require_relative 'match'


module TsungWrapper

	class ConfigLoader

		@@automatic_attrs = [	:server_host, 
													:base_url, 
													:maxusers, 
													:server_port, 
													:http_version, 
													:dumptraffic, 
													:loglevel, 
													:default_thinktime
												]

		attr_reader  	:user_agents, :default_matches, :base_url_and_port, :username, :password
		attr_accessor :load_profile

		attr_reader *@@automatic_attrs

		def initialize(env)
			@load_profile = nil
			@user_agents  = []

		  filename = File.expand_path(File.join(TsungWrapper.config_dir, 'environments', "#{env}.yml"))
		  unless File.exist?(filename)
		  	raise ArgumentError.new("Configuration file for environment '#{env}' does not exist.")
		  end
		  config = YAML.load_file(filename)

		  raise "No Load profile specified in #{filename}" if config['load_profile'].nil?

		  @@automatic_attrs.each do |attr|
		  	varname = "@#{attr}".to_sym
		  	self.instance_variable_set(varname, config[attr.to_s])
		  end

		  config['user_agents'].each do |ua|
		  	@user_agents << OpenStruct.new(ua)
		  end

		  @default_matches = []
		  unless config['default_matches'].nil?
		  	config['default_matches'].each { | matchname| @default_matches << Match.new(matchname) }
		  end

		  @load_profile = LoadProfile.new(config['load_profile'])
		  @dumptraffic = "false" if @dumptraffic.nil?
		  @loglevel = "notice" if @loglevel.nil?
		  @base_url_and_port = combine_url_and_port(@base_url, @server_port)

		  if config.key? 'http_basic_auth'
		  	@username = config['http_basic_auth']['username']
		  	@password = config['http_basic_auth']['password']
		  else
		  	@username = @password = nil
		  end
		end


		def combine_url_and_port(url, port)
			url =~ /^(https?:\/\/[^\/]+)(\/.*)?/
			"#{$1}:#{port.to_s}#{$2}"
		end



		def http_basic_auth?
			!@username.nil? && !@password.nil?
		end

		def ignore_thinktimes?
			@default_thinktime == 0
		end




		def register_load_profile(lp_name)
			builder = @load_profile.builder
			@load_profile = LoadProfile.new(lp_name)
			@load_profile.builder = builder
		end
		

	end

end