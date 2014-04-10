require 'spec_helper'
require_relative '../lib/snippet'

module TsungWrapper

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





	end

end


# thinktime: 6
#   name: Login
#   url: '/user/login'
#   http_method: POST
#   params:
#     email: test@test.com
#     password: Abc123123
#     submit: Sign in



