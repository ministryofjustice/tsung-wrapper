require 'yaml'
require 'ostruct'

module TsungWrapper

	class ConfigLoader

		@@automatic_attrs = [:server_host, :base_url, :maxusers, :server_port, :http_version]
		attr_reader :arrivalphases, :user_agents

		attr_reader *@@automatic_attrs

		def initialize(env)
			@arrivalphases = []
			@user_agents   = []

		  filename = File.expand_path(File.join(TsungWrapper.config_dir, 'environments', "#{env}.yml"))
		  unless File.exist?(filename)
		  	raise ArgumentError.new("Configuration file for environment '#{env}' does not exist.")
		  end
		  config = YAML.load_file(filename)

		  @@automatic_attrs.each do |attr|
		  	varname = "@#{attr}".to_sym
		  	self.instance_variable_set(varname, config[attr.to_s])
		  end

		  config['arrivalphases'].each do |ap|
		  	@arrivalphases << OpenStruct.new(ap)
		  end

		  config['user_agents'].each do |ua|
		  	@user_agents << OpenStruct.new(ua)
		  end
		end
		

	end

end