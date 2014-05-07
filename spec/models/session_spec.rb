
require 'builder'
require_relative '../spec_helper'
require_relative '../../lib/session'
require_relative '../../lib/config_loader'


module TsungWrapper

	describe Session do

		let(:xml)							{ "" }
		let(:builder)					{ Builder::XmlMarkup.new(:target => xml, :indent => 2) }
		let(:config)					{ ConfigLoader.new('test') }

		describe '.new' do

			it 'should raise an exception if no session file exists with the specified name' do
				expect {
					Session.new('non_existent_session', builder, config, 40)
				}.to raise_error ArgumentError, "No session found with name 'non_existent_session'"
			end


			it 'should raise an exception if the session contains non-existent snippets' do
				expect{
					Session.new('session_including_missing_snippet', builder, config, 70)
				}.to raise_error ArgumentError, "No Snippet with the name 'no_such_snippet' can be found."
			end

			it 'should load dynvars' do
				session = Session.new('dynvar_session', builder, config, 30)
				session.has_dynvars?.should be_true
				dv = session.dynvars.first
				dv.type.should == 'random_string'
			end



			it 'should load the session and component snippets' do
				session = Session.new('hit_landing_page', builder, config, 20)
				session.session_name.should == 'hit_landing_page'
				session.snippets.size.should == 2
				session.has_dynvars?.should be_false
				session.instance_variable_get(:@probability).should == 20

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


		describe 'file_dynvars' do 
			it 'should return an empty array if there are no dynvars' do
				session = Session.new('hit_landing_page', builder, config, 20)
				session.file_dynvars.should be_empty
			end


			it 'should return an empty array if there are only non-file dynvars' do
				session = Session.new('dynvar_session', builder, config, 20)
				session.file_dynvars.should be_empty
			end

			it 'should return an array of multiple file_dynvars if more than one dynvar in session' do
				session = Session.new('multi_file_dynvar_session', builder, config, 20)
				session.file_dynvars.size.should == 2
				session.file_dynvars.map(&:fileid).should == [ Digest::MD5.hexdigest('username_a.csv'), Digest::MD5.hexdigest('username_b.csv') ]
			end

			it 'should not return duplicate copies of dynvars with same fileid' do
				session = Session.new('file_dynvar_session', builder, config, 20)
				session.file_dynvars.size.should == 1
			end
			
		end

	end

end
