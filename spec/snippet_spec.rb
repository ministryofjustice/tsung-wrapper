require 'spec_helper'
require_relative '../lib/snippet'

module TsungWrapper
	include TsungWrapperSpecHelper

	describe Snippet do

		describe '.new' do
			it 'should raise an exception if the snippet file doesnt exist' do
				expect {
					Snippet.new('missing_snippet')
				}.to raise_error ArgumentError, "No Snippet with the name 'missing_snippet' can be found."
			end
		end

		describe 'method missing'  do
			let(:snippet)   { Snippet.new("login_with_think_time") }
			
			it 'should return the values if they exist' do
				snippet.thinktime.should == 6
				snippet.url.should == '/user/login'
				snippet.http_method.should == 'POST'
			end

			it 'should raise to super if no attribute of that name' do
				expect {
					snippet.no_such_method
				}.to raise_error NoMethodError, /undefined method .no_such_method/
				
			end
		end

		describe '#has_attribute?' do
			it 'should return true if the attribute is present' do
				snippet = Snippet.new('login_with_think_time')
				snippet.has_attribute?('thinktime').should be_true
			end

			it 'should return false if the attribute is not present' do
				snippet = Snippet.new('hit_landing_page')
				snippet.has_attribute?('thinktime').should be_false
			end
		end


		describe '#has_params?' do
			it 'should return true for snippets with params' do
				snippet = Snippet.new('login_with_think_time')
				snippet.has_params?.should be_true
			end

			it 'should return false for snippets without params' do
				snippet = Snippet.new('hit_landing_page')
				snippet.has_params?.should be_false
			end
		end 


		describe '#has_extract_dynvars?' do
			it 'should return false if there are no dynvars to be extracted' do
				snippet = Snippet.new('hit_landing_page')
				snippet.has_extract_dynvars?.should be_false
			end

			it 'should return true if dynvars are to be extracted' do
				snippet = Snippet.new('register_user_and_store_authurl')
				snippet.has_extract_dynvars?.should be_true
			end
		end

		context 'extract dynvars' do
			it 'should return empty hash if there are no extracted dynvars' do
				snippet = Snippet.new('hit_landing_page')	
				snippet.extract_dynvars.should == {}
			end

			it 'should return populated hash if there are extracted dynvars' do
				snippet = Snippet.new('register_user_and_store_authurl')
				snippet.extract_dynvars.should == {
					'activationurl'				=> "id='activation_link' href='(.*)'",
					'page_title'			   	=> "&lt;title&gt;(.*)&lt;/title&gt;"
				}
			end
		end


		describe '#is_get?' do
			it 'should return true for gets' do
				snippet = Snippet.new('hit_landing_page')
				snippet.is_get?.should be_true
			end

			it 'should return false for posts' do
				snippet = Snippet.new('login_using_dynvars')
				snippet.is_get?.should be_false
			end
		end


		describe '#is_post?' do
			it 'should return false for gets' do
				snippet = Snippet.new('hit_landing_page')
				snippet.is_post?.should be_false
			end

			it 'should return true for posts' do
				snippet = Snippet.new('login_using_dynvars')
				snippet.is_post?.should be_true
			end
		end


		describe '#params' do
			it 'should return a list of parameter names' do
				snippet = Snippet.new('login_with_think_time')
				snippet.params.should == ['email', 'password', 'submit']
			end

			it 'should return an empty arry if there are no params' do
				snippet = Snippet.new('hit_landing_page')
				snippet.params.should == []
			end
		end


		describe '#has_dynvars?' do
			it 'should return false if there are no parameters' do
				snippet = Snippet.new('hit_landing_page')
				snippet.has_dynvars?.should be_false
			end

			it 'should return false if the parameters do not contains dynvars' do
				snippet = Snippet.new('login_with_random_user_name')
				snippet.has_dynvars?.should be_false
			end

			it 'should return true if at least one param contains a dynvar' do
				snippet = Snippet.new('login_using_dynvars')
				snippet.has_dynvars?.should be_true
			end

			it 'should return true if the url is specified as a dynvar' do
				snippet = Snippet.new('activate_account')
				snippet.has_dynvars?.should be_true
			end
		end


		describe 'has_url_dynvar?' do
			
			it 'should return true if the url is a dynvar' do
				snippet = Snippet.new('activate_account')
				snippet.has_url_dynvar?.should be_true
			end

			it 'should return false if the url is not a dynvar' do
				snippet = Snippet.new('login_using_dynvars')
				snippet.has_url_dynvar?.should be_false
			end
		end


		describe '#param' do
			it 'should return the CGI encoded value of the param' do
				snippet = Snippet.new('login_with_think_time')
				snippet.param('email').should == 'test%40test.com'
				snippet.param('password').should == 'Abc123123'
				snippet.param('submit').should == 'Sign+in'
			end

			it 'should return nil if there is no such parameter' do
				snippet = Snippet.new('login_with_think_time')
				snippet.param('surname').should be_nil
			end

			it 'should return nil if there are no parameters' do
				snippet = Snippet.new('hit_landing_page')
				snippet.param('email').should be_nil
			end
		end

		describe '#content_string' do
			it 'should return an encoded parameter string' do
				snippet = Snippet.new('login_with_think_time')
				snippet.content_string.should == :'email=test%40test.com&amp;password=Abc123123&amp;submit=Sign+in'
			end
		end


		describe '#matches' do
			it 'should return an empty array if there are no matches' do
				snippet = Snippet.new('login_with_think_time')
				snippet.matches.should be_instance_of(Array)
				snippet.matches.should be_empty
			end

			it 'should return an array of OpenStructs containing match attributes' do
				snippet = Snippet.new('login_with_dynvar_and_match_response')
				snippet.matches.size.should == 2
				
				match = snippet.matches.first

				match.name.should == 'dump_non_200_response'
				match.when.should == 'nomatch'
				match.do.should == 'dump'
				match.source.should == 'all'
				match.pattern.should == 'HTTP/1.1 200'

				match = snippet.matches.last
				match.name.should == 'match_200_response'
				match.when.should ==  'match' 	
				match.do.should == 'continue'									
				match.source.should ==  'all'                       
				match.pattern.should == "HTTP/1.1 200" 
			end
		end


		describe '#add_default_matches'  do
			it 'should not replace existing matches with default matches' do
				# given a config with matches ...
				config = ConfigLoader.new('test_with_unique_matches')
				config.default_matches.first.name.should == 'dump_4xx'
				config.default_matches.last.name.should == 'continue_if_200_or_302'

				# ... and a snippet with matches
				snippet = Snippet.new('login_with_dynvar_and_match_response')
				snippet.matches.size == 2
				snippet.matches.first.name.should == 'dump_non_200_response'
				snippet.matches.last.name.should == 'match_200_response'

				# when we add default matches
				snippet.add_default_matches(config)

				# the matches in the snippet should not be changed
				snippet.matches.size == 2
				snippet.matches.first.name.should == 'dump_non_200_response'
				snippet.matches.last.name.should == 'match_200_response'
			end


			it 'should insert default matches when matches are empty' do
				# given a config with matches ....
				config = ConfigLoader.new('test_with_unique_matches')
				config.default_matches.first.name.should == 'dump_4xx'
				config.default_matches.last.name.should == 'continue_if_200_or_302'

				# ... and a snippet with no matches
				snippet = Snippet.new('activate_account')
				snippet.matches.should be_empty

				#when I add default matchest
				snippet.add_default_matches(config)

				# the snippet should have the same matches as the config
				snippet.matches.first.name.should == 'dump_4xx'
				snippet.matches.last.name.should == 'continue_if_200_or_302'
			end


			it 'should insert empty array when there are no matches nor default matches' do
				# given a sconfig with no default matches ...
				config = ConfigLoader.new('development')

				# and a snippet with no default matches
				snippet = Snippet.new('activate_account')

				# When I add default matches to the snippet
				snippet.add_default_matches(config)

				# the snippet whould have no matches
				snippet.matches.should be_empty
			end


		end
 


	end

end


