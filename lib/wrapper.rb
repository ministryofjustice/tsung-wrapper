
require 'builder'
require 'tsung_wrapper'
require 'config_loader'
require 'session'


module TsungWrapper

	class Wrapper

		def initialize(session, env = nil)
			@session = Session.new(session)
			@env     = env.nil? ? 'development' : env
			@config  = ConfigLoader.new(@env)
			@xml     = ""
		  @builder = Builder::XmlMarkup.new(:target => @xml, :indent => 2)
		  @builder.instruct! :xml, :encoding => "UTF-8"
		  @builder.declare! :DOCTYPE, :tsung, :SYSTEM, "#{TsungWrapper.dtd}"
		end

		def wrap 
			@builder.tsung('loglevel' => 'notice', 'version' => '1.0') do 
				add_standard_client_element
				add_standard_server_element
				add_load_element
				add_user_agent_element
			end
			@xml
		end		




		private





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

