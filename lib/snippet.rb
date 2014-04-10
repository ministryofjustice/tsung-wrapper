module TsungWrapper

	class Snippet


		def initialize(snippet_name)
			filename = "#{TsungWrapper.config_dir}/snippets/#{snippet_name}.yml"
			unless File.exist?(filename)
				raise ArgumentError.new("No Snippet with the name '#{snippet_name}' can be found.")
			end

			config = YAML.load_file(filename)
			@attrs = OpenStruct.new(config['request'])
		end


		def method_missing(meth)
			@attrs[meth.to_s].nil? ? super : @attrs[meth.to_s]
		end
		

	end

end