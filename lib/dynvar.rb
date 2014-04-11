require_relative 'tsung_wrapper'


module TsungWrapper

	class Dynvar

		attr_reader :varname, :type, :length, :start, :end, :code

		def initialize(dynvar_definition_name, varname)
			# @attrs  = []
		  @type    = nil
		  @length  = nil
		  @start   = nil
		  @end     = nil
		  @code    = nil
		  @varname = varname

			filename = File.join(TsungWrapper.config_dir, 'dynvars', "#{dynvar_definition_name}.yml")
		  unless File.exist?(filename)
		  	raise ArgumentError.new("No Dynamic Variable snippet with name '#{dynvar_definition_name}' can be found.")
		  end

		  @config = YAML.load_file(filename)['dynvar']
		  valid_types = %w{ random_string random_number erlang }
		  unless valid_types.include?(@config['type'])
		  	raise ArgumentError.new("Invalid type '#{@config['type']}' defined in Dynamic Variable snippet.")
		  end

		  case @config['type']
		  when 'random_string'
		  	populate_random_string
		  when 'random_number'
		  	populate_random_number
		  when 'erlang'
		  	populate_erlang
		  end
		end

		# produces a hash which can be passed as the attributes to the <setdynvars> element
		def attr_hash
			hash = {:sourcetype => @type}
			case @type
			when 'random_string'
				hash[:length] = @length
			when 'random_number'
				hash[:start] = @start
				hash[:end] = @end
			when 'eval'
				hash[:code] = @code.chomp.to_sym			# symbolize it in order to prevent it from being escaped
			end
			hash
		end




		private

		def populate_random_string
			@attrs  = [:sourcetype, :length]
			@type   = 'random_string'
			@length = @config['length']
		end


		def populate_random_number
			@attrs = [:sourcetype, :start, :end]
			@type  = 'random_number'
			@start = @config['start']
			@end   = @config['end']
		end


		def populate_erlang
			@attrs = [:sourcetype, :code]
			@type  = 'eval'
			@code  = @config['code']
		end
	end

end
