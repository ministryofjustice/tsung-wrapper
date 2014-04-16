require 'spec_helper'
require_relative '../lib/config_loader'

module TsungWrapper


	describe ConfigLoader do

		describe '.new' do
			it 'should raise an exception if the required environment yaml file does not exist' do
				expect{
					ConfigLoader.new('invisible')
				}.to raise_error ArgumentError, "Configuration file for environment 'invisible' does not exist."
			end

			it 'should load the appropriate file and return the correct variables' do
				config = ConfigLoader.new('test')
				config.server_host.should == 'test_server_host'
				config.base_url.should == 'http://test_base_url.com'
				config.maxusers.should == 1500
				config.server_port.should == 80
				config.load_profile.num_phases.should == 3
				config.http_version.should == 1.1

				config.user_agents.size.should == 2
				ua = config.user_agents.first
				ua.name.should == 'Linux Firefox'
				ua.probability.should == 80
				ua.user_agent_string.should == 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21'

				ua = config.user_agents.last
				ua.name.should == 'Windows Firefox'
				ua.probability.should == 20
				ua.user_agent_string.should == 'Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4'
			end
		end

		describe '#register_load_profile' do
			it 'should override the existing load profiles with the new ones' do
				config = ConfigLoader.new('test')
				config.load_profile.num_phases.should == 3
				config.register_load_profile('minimal')
				config.load_profile.num_phases.should == 1
			end			
		end

	end
end


