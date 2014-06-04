require_relative '../spec_helper'
require_relative '../../lib/config_loader'

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
				config.default_thinktime.should == 0

				config.default_matches.size.should == 2
				config.default_matches.first.name.should == 'dump_non_200_response'
				config.default_matches.last.name.should == 'match_200_response'

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

			it 'should initialise and empty array of default matches if default matches not specified in environment file' do
				config = ConfigLoader.new('development')
				config.default_matches.should be_instance_of(Array)
				config.default_matches.size.should == 0
			end

			it 'should raise if the environment config doesnt have a load profile' do
				expect {
					config = ConfigLoader.new('test_without_load_profile')
				}.to raise_error RuntimeError, /^No Load profile specified in.*test_without_load_profile\.yml$/
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


		describe 'private method combine_url_and_port' do
			let(:config)  { ConfigLoader.new('test') }

			it 'should add port to https url with actions' do
				config.send(:combine_url_and_port, 'https://my_base_url/action/action', 443).should == 'https://my_base_url:443/action/action'
			end

			it 'should add port to the https url when no actions after the base url' do
				config.send(:combine_url_and_port, 'https://my_base_url', 443).should == 'https://my_base_url:443'
			end

			it 'should  add port to the https url when there are no actions and the base url end in /' do
				config.send(:combine_url_and_port, 'https://my_base_url/', 443).should == 'https://my_base_url:443/'
			end

			it 'should add port to http url with actions' do
				config.send(:combine_url_and_port, 'http://my_base_url/action/action', 443).should == 'http://my_base_url:443/action/action'
			end

			it 'should add port to the http url when no actions after the base url' do
				config.send(:combine_url_and_port, 'http://my_base_url', 443).should == 'http://my_base_url:443'
			end

			it 'should  add port to the http url when there are no actions and the base url end in /' do
				config.send(:combine_url_and_port, 'http://my_base_url/', 443).should == 'http://my_base_url:443/'
			end
		end


		context 'http_basic_auth' do
			
			let(:config_without_auth) 	{ ConfigLoader.new('test') }
			let(:config_with_auth)			{ ConfigLoader.new('test_with_basic_auth') }

			describe '#http_basic_auth?' do
				
				it 'should be false if there is no basic auth' do
					config_without_auth.http_basic_auth?.should be_false
				end

				it 'should return true if basic auth is enabled' do
					config_with_auth.http_basic_auth?.should be_true
				end
			end


			describe 'username' do
				it 'should return nil if there is no auth' do
					config_without_auth.username.should be_nil
				end

				it 'should return username if there is auth' do
					config_with_auth.username.should == 'monkey'
				end
			end

			describe 'password' do
				it 'should return nil if there is no auth' do
					config_without_auth.password.should be_nil
				end

				it 'should return username if there is auth' do
					config_with_auth.password.should == 'business'
				end
			end
		end

	end
end


