require_relative 'tsung_wrapper'


module TsungWrapper

	class Dynvar

		attr_reader :attrs, :type, :length, :start, :end, :code

		def initialize(dynvar_name)
			@attrs  = []
		  @type   = nil
		  @length = nil
		  @start  = nil
		  @end    = nil
		  @code   = nil

			filename = File.join(TsungWrapper.config_dir, 'dynvars', "#{dynvar_name}.yml")
		  unless File.exist?(filename)
		  	raise ArgumentError.new("No Dynamic Variable snippet with name '#{dynvar_name}' can be found.")
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


		private

		def populate_random_string
			@attrs  = [:type, :length]
			@type   = 'random_string'
			@length = @config['length']
		end


		def populate_random_number
			@attrs = [:type, :start, :end]
			@type  = 'random_number'
			@start = @config['start']
			@end   = @config['end']
		end


		def populate_erlang
			@attrs = [:type, :code]
			@type  = 'eval'
			@code  = @config['code']
		end

		
	end

end
