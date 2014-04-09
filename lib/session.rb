require 'yaml'
require 'ostruct'


module TsungWrapper

	# This class models an http session as that will be incorporated
	# into the Tsung XML file.  It's sole job is to load the named config
	# and all the component snippets so that they can be presented to the Wrapper

	class Session

		attr_reader :snippets, :session_name

		def initialize(session_name)
			@session_name = session_name
			filename = "#{::TsungWrapper.config_dir}/sessions/#{@session_name}.yml"
			
			unless File.exist?(filename)
				raise ArgumentError.new("No session found with name '#{@session_name}'")
			end
			session = YAML.load_file(filename)
			snippet_names = session['session']['snippets']
			@snippets = []
			build_snippets(snippet_names)
		end
		

		private 

		def build_snippets(snippet_names)
			snippet_names.each { |s| build_snippet(s) }
		end


		def build_snippet(snippet)
			filename = "#{TsungWrapper.config_dir}/snippets/#{snippet}.yml"
			unless File.exist?(filename)
				raise ArgumentError.new("The session '#{@session_name}' refers to a snippet '#{snippet}' which cannot be found.")
			end

			config = YAML.load_file(filename)
			@snippets << OpenStruct.new(config['request'])
		end

	

	end

end