require 'yaml'
require 'ostruct'
require_relative 'load_profile'

module TsungWrapper

	class ConfigLoader

		@@automatic_attrs = [:server_host, :base_url, :maxusers, :server_port, :http_version]
		attr_reader  	:user_agents
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

		  @@automatic_attrs.each do |attr|
		  	varname = "@#{attr}".to_sym
		  	self.instance_variable_set(varname, config[attr.to_s])
		  end

		  # config['arrivalphases'].each do |ap|
		  # 	@arrivalphases << OpenStruct.new(ap)
		  # end

		  config['user_agents'].each do |ua|
		  	@user_agents << OpenStruct.new(ua)
		  end

		  @load_profile = LoadProfile.new(config['load_profile'])
		end

		def register_load_profile(lp_name)
			builder = @load_profile.builder
			@load_profile = LoadProfile.new(lp_name)
			@load_profile.builder = builder
		end
		

	end

end