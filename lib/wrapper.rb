
require 'builder'
require_relative 'tsung_wrapper.rb'
require_relative 'config_loader'
require_relative 'session'


module TsungWrapper

	class Wrapper

		def initialize(session, env = nil, snippet_only = false, snippet_name = nil)
			TsungWrapper.env = env
			@snippet_only    = snippet_only
			@snippet_name    = snippet_name
			@env             = env.nil? ? 'development' : env
			@config          = ConfigLoader.new(@env)
			@xml             = ""
		  @builder 				 = Builder::XmlMarkup.new(:target => @xml, :indent => 2)
		  
		  unless @snippet_only
		  	@session = Session.new(session)
			  @builder.instruct! :xml, :encoding => "UTF-8"
			  @builder.declare! :DOCTYPE, :tsung, :SYSTEM, "#{TsungWrapper.dtd}"
			end
		end


		def self.xml_for_snippet(snippet_name)
			wrapper = self.new(nil, 'test', true, snippet_name)
			wrapper.wrap_snippet
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
			raise "Unable to call wrap_snippet on a Wrapper that wasn't instantiated using xml_for_snippet()" unless @snippet_only == true
			snippet = Snippet.new(@snippet_name)
			transform_snippet(snippet)
		end





		private


		


		def formatted_time
			Time.now.strftime('%Y%m%d-%H%M%S')
		end


		def make_url(config, snippet)
			url = nil
			if snippet.url.nil?
				url = config.base_url
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
			@builder.request do 
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



		def add_sessions
			@builder.sessions do
				@builder.session(:name => "#{@session.session_name}-#{formatted_time}", :probability => 100, :type => 'ts_http') do 
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
			@builder.load do 
				@config.arrivalphases.each do |phase|
					@builder.comment! "Scenario #{phase.sequence}: #{phase.name}"
					@builder.arrivalphase(:phase => phase.sequence, :duration => phase.duration, :unit => phase.duration_unit) do
						@builder.users(:interarrival => phase.arrival_interval, :unit => phase.arrival_interval_unit)
					end
				end
			end
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

