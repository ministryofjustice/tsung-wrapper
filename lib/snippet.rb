require 'ostruct'
require 'cgi'


module TsungWrapper

	class Snippet


		def initialize(snippet_name)
			filename = "#{TsungWrapper.config_dir}/snippets/#{snippet_name}.yml"
			unless File.exist?(filename)
				raise ArgumentError.new("No Snippet with the name '#{snippet_name}' can be found.")
			end

			config = YAML.load_file(filename)
			@attrs = config['request']
			@params = @attrs['params'].nil? ? {} : @attrs['params']
		end

		# returns the keys of the params that are stored
		def params
			@params.keys
		end

		def param(key)
			@params.has_key?(key) ? CGI.escape(@params[key]) : nil
		end


		def method_missing(meth)
			stringified_meth = meth.to_s
			@attrs.has_key?(stringified_meth) ? @attrs[stringified_meth] : super
		end
		

	end

end