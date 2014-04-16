
require 'builder'
require_relative 'tsung_wrapper.rb'
require_relative 'config_loader'
require_relative 'session'
require_relative 'load_profile'

module TsungWrapper

	class Wrapper

		# Instantiate a Wrapper.  Usual invocation is:
		#
		#    TsungWrapper::Wrapper.new("my_session") 
		#    TsungWrapper::Wrapper.new("my_session", "staging")
		#
		# For testing purposes, Wrapper objects can be instantiated just to emit the xml for snippets or dynvars:
		#
		# 		TsungWrapper::Wrapper.new("my_session", "test", :snippet, 'my_snippet')
		#  		TsungWrapper::Wrapper.new("my_session", "test", :dynvar, '"my_dynvar"')
		#
		def initialize(session, env = nil, xml_to_generate = :full, snippet_name = nil)
			TsungWrapper.env = env
			@wrapper_type    = xml_to_generate
			@snippet_name    = @wrapper_type == :snippet ? snippet_name : nil
			@dynvar_name     = @wrapper_type == :dynvar  ? snippet_name : nil
			@env             = env.nil? ? 'development' : env
			@config          = ConfigLoader.new(@env)
			@xml             = ""
		  @builder 				 = Builder::XmlMarkup.new(:target => @xml, :indent => 2)

		  @config.load_profile.set_xml_builder(@builder)
		  if @wrapper_type == :full
		  	@session = Session.new(session)
			  @builder.instruct! :xml, :encoding => "UTF-8"
			  @builder.declare! :DOCTYPE, :tsung, :SYSTEM, "#{TsungWrapper.dtd}"
			end
		end

		def register_load_profile(lp_name)
			@config.register_load_profile(lp_name)
		end



		# this method is used for testing only
		def self.xml_for_snippet(snippet_name)
			wrapper = self.new(nil, 'test', :snippet, snippet_name)
			wrapper.wrap_snippet
		end


		def self.xml_for_dynvar(dynvar_name, varname)
			wrapper = self.new(nil, 'test', :dynvar, dynvar_name)
			wrapper.wrap_dynvar(varname)
		end


		def wrap 
			@builder.tsung('loglevel' => 'notice', 'version' => '1.0') do 
				add_standard_client_element
				add_standard_server_element
				add_load_element
				add_user_agent_element
				add_sessions
			end
			@xml
		end		


		def wrap_snippet
			raise "Unable to call wrap_snippet on a Wrapper that wasn't instantiated using xml_for_snippet()" unless @wrapper_type == :snippet
			snippet = Snippet.new(@snippet_name)
			transform_snippet(snippet)
			@xml
		end



		def wrap_dynvar(varname)
			raise "Unable to call wrap_dynvar on a Wrapper that wasn't instantiated using xml_for_dynvar()" unless @wrapper_type == :dynvar
			dynvar = Dynvar.new(@dynvar_name, varname)
			add_dynvar(dynvar)
			@xml
		end



		private


		


		def formatted_time
			Time.now.strftime('%Y%m%d-%H%M%S')
		end

		# makes the url from the snippet and the config
		# if the snippet is a dynvar, than it is not appended to the base_url
		def make_url(config, snippet)
			url = nil
			if snippet.url.nil?
				url = config.base_url
			elsif snippet.has_url_dynvar?
				url = snippet.url
			else
				protocol, resource = config.base_url.split('://')
				resource = resource + '/' + snippet.url
				url = protocol + '://' + resource.gsub('//', '/')
			end
			url
		end



		# expects and OpenStruct 
		def transform_snippet(snippet)
			@builder.comment! snippet.name

			if snippet.has_attribute?('thinktime')
				@builder.thinktime(:random => true, :value => snippet.thinktime)
			end

			request_attrs = snippet.has_dynvars? ? {:subst => true} : nil
			@builder.request(request_attrs) do 
				add_matches(snippet.matches)
				add_extract_dynvars(snippet) if snippet.has_extract_dynvars?
				if snippet.has_params?
					@builder.http(:url => make_url(@config, snippet), 
												:version => @config.http_version, 
												:contents => snippet.content_string,
												:content_type => "application/x-www-form-urlencoded",
												:method => snippet.http_method)
				else
					@builder.http(:url => make_url(@config, snippet), :version => @config.http_version, :method => snippet.http_method)
				end
			end
		end


		def add_extract_dynvars(snippet)
			snippet.extract_dynvars.keys.each do |name|
				@builder.dyn_variable(:name => name, :re => snippet.extract_dynvars[name])
			end
		end



		def add_matches(matches)
			matches.each do |match| 
				@builder.match(match.pattern, :do => match.do, :when => match.when, :name => match.name)
			end
		end



		def add_dynvar(dynvar)
			@builder.setdynvars(dynvar.attr_hash) do
				@builder.var(:name => dynvar.varname)
			end
		end



		def add_sessions
			@builder.sessions do
				@builder.session(:name => "#{@session.session_name}-#{formatted_time}", :probability => 100, :type => 'ts_http') do 
					@session.dynvars.each do |dynvar|
						add_dynvar(dynvar)
					end
					@session.snippets.each do |snippet|
						transform_snippet(snippet)
					end
				end
			end
		end


		def add_user_agent_element
			@builder.comment! "Define User Agents"
			@builder.options do
				@builder.option(:type => 'ts_http', :name => 'user_agent') do
					@config.user_agents.each do |ua|
						@builder.user_agent(ua.user_agent_string, :probability => ua.probability) 
					end
				end
			end
		end



		def add_load_element
			@config.load_profile.to_xml
		end




		def add_standard_client_element
			@builder.comment! "Client Side Setup"
			@builder.clients do
				@builder.client(:host => 'localhost', :use_controller_vm => 'true', :maxusers => @config.maxusers)
			end
		end


		def add_standard_server_element
			@builder.comment! "Server Side Setup"
			@builder.servers do
				@builder.server(:host => @config.server_host, :port => @config.server_port, :type => 'tcp')
			end


		end

	end
end

