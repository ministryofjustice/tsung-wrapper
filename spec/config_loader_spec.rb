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
				config.base_url.should == 'http://test_base_url'
				config.maxusers.should == 40
				config.server_port.should == 8080
				config.arrivalphases.size.should == 3
				config.http_version.should == 1.1

				ap = config.arrivalphases.first
				ap.name.should == 'Average Load'
				ap.sequence.should == 1
				ap.duration.should == 10
				ap.duration_unit.should == 'minute'
				ap.arrival_interval.should == 30
				ap.arrival_interval_unit.should == 'second'

				ap = config.arrivalphases.last
				ap.name.should == 'Very High Load'
				ap.sequence.should == 3
				ap.duration.should == 5
				ap.duration_unit.should == 'minute'
				ap.arrival_interval.should == 2
				ap.arrival_interval_unit.should == 'second'

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

	end
end


