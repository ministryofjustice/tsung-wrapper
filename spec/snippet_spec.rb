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
				match.pattern.should == 'HTTP/1.1 (200'

				match = snippet.matches.last
				match.name.should == 'match_200_response'
				match.when.should ==  'match' 	
				match.do.should == 'continue'									
				match.source.should ==  'all'                       
				match.pattern.should == "HTTP/1.1 (200" 


			end
		end
 


	end

end


