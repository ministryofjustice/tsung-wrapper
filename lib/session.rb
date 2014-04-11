require 'yaml'
require 'ostruct'

require_relative 'snippet'
require_relative 'dynvar'


module TsungWrapper

	# This class models an http session as that will be incorporated
	# into the Tsung XML file.  It's sole job is to load the named config
	# and all the component snippets so that they can be presented to the Wrapper

	class Session

		attr_reader :snippets, :session_name, :dynvars

		def initialize(session_name)
			@session_name = session_name
			@dynvars      = []
			@snippets     = []
			filename      = "#{TsungWrapper.config_dir}/sessions/#{@session_name}.yml"
			
			unless File.exist?(filename)
				raise ArgumentError.new("No session found with name '#{@session_name}'")
			end
			session = YAML.load_file(filename)['session']
			if session.has_key?('dynvars')
				build_dynvars(session['dynvars'])
			end
			snippet_names = session['snippets']
			build_snippets(snippet_names)
		end
		
		def has_dynvars?
			@dynvars.any?
		end


		private 

		def build_snippets(snippet_names)
			snippet_names.each { |s| build_snippet(s) }
		end

		def build_dynvars(dynvars_hash)
			dynvars_hash.each do |varname, dynvar_definition_name|
				@dynvars << Dynvar.new(dynvar_definition_name, varname)
			end
		end


		def build_snippet(snippet_name)
			@snippets << Snippet.new(snippet_name)
		end

	

	end

end