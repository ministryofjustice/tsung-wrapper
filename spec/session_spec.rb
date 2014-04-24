require 'spec_helper'
require 'builder'

require_relative '../lib/session'
require_relative '../lib/config_loader'


module TsungWrapper

	describe Session do

		describe '.new' do
			let(:xml)							{ "" }
			let(:builder)					{ Builder::XmlMarkup.new(:target => xml, :indent => 2) }
			let(:config)					{ ConfigLoader.new('test') }

			it 'should raise an exception if no session file exists with the specified name' do
				expect {
					Session.new('non_existent_session', builder, config)
				}.to raise_error ArgumentError, "No session found with name 'non_existent_session'"
			end


			it 'should raise an exception if the session contains non-existent snippets' do
				expect{
					Session.new('session_including_missing_snippet', builder, config)
				}.to raise_error ArgumentError, "No Snippet with the name 'no_such_snippet' can be found."
			end

			it 'should load dynvars' do
				session = Session.new('dynvar_session', builder, config)
				session.has_dynvars?.should be_true
				dv = session.dynvars.first
				dv.type.should == 'random_string'
			end



			it 'should load the session and component snippets' do
				session = Session.new('hit_landing_page', builder, config)
				session.session_name.should == 'hit_landing_page'
				session.snippets.size.should == 2
				session.has_dynvars?.should be_false

				snippet = session.snippets.first
				snippet.name.should == "Hit Landing Page"
				snippet.url.should be_nil
				snippet.http_method.should == 'GET'

				snippet = session.snippets.last
				snippet.name.should == "Hit Register Page"
				snippet.url.should == '/user/register'
				snippet.http_method.should == 'GET'
			end
		end

	end

end
