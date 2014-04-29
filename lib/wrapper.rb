
require 'builder'
require_relative 'tsung_wrapper.rb'
require_relative 'config_loader'
require_relative 'session'
require_relative 'load_profile'
require_relative 'scenario'

module TsungWrapper

	class Wrapper

		# Instantiate a Wrapper.  Usual invocation is:
		#
		#    TsungWrapper::Wrapper.new("session_or_scenario_name") 
		#    TsungWrapper::Wrapper.new("session_or_scenario_name", "staging")
		#
		
		def initialize(session_or_scenario, env = nil)
			TsungWrapper.env = env
			@env             = env.nil? ? 'development' : env
			@config          = ConfigLoader.new(@env)
			@xml             = ""
		  @builder 				 = Builder::XmlMarkup.new(:target => @xml, :indent => 2)

		  @config.load_profile.set_xml_builder(@builder)
		  @scenario = Scenario.new(session_or_scenario, @builder, @config)


	  	# @session = Session.new(session, @builder, @config)
		  @builder.instruct! :xml, :encoding => "UTF-8"
		  @builder.declare! :DOCTYPE, :tsung, :SYSTEM, "#{TsungWrapper.dtd}"
		end

		def register_load_profile(lp_name)
			@config.register_load_profile(lp_name)
		end



		def wrap 
			@builder.tsung(:loglevel => @config.loglevel, :dumptraffic => @config.dumptraffic, :version => '1.0') do 
				add_standard_client_element
				add_standard_server_element
				add_load_element
				add_options_element
				add_scenario
			end
			@xml
		end		





		private

		def add_scenario
			@scenario.to_xml
		end

		def add_options_element
			@builder.options do
				add_file_dynvar_options
				add_user_agent_element
			end
		end


		def add_user_agent_element
			@builder.comment! "Define User Agents"
			@builder.option(:type => 'ts_http', :name => 'user_agent') do
				@config.user_agents.each do |ua|
					@builder.user_agent(ua.user_agent_string, :probability => ua.probability) 
				end
			end
		end


		def add_file_dynvar_options
			if @scenario.file_dynvars.any?
				@scenario.file_dynvars.each do |fd|
					@builder.option(:name => 'file_server', :id => fd.fileid, :value => fd.filepath)
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

