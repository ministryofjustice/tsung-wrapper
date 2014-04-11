require 'spec_helper'
require_relative '../lib/session'

module TsungWrapper

	describe Session do

		describe '.new' do

			it 'should raise an exception if no session file exists with the specified name' do
				expect {
					Session.new('non_existent_session')
				}.to raise_error ArgumentError, "No session found with name 'non_existent_session'"
			end


			it 'should raise an exception if the session contains non-existent snippets' do
				filename = "#{TsungWrapper.config_dir}/sessions/my_session.yml"
				snippet_1_filename = "#{TsungWrapper.config_dir}/snippets/hit_landing_page.yml"
				snippet_2_filename = "#{TsungWrapper.config_dir}/snippets/non_existent_snippet.yml"
				snippet_3_filename = "#{TsungWrapper.config_dir}/snippets/hit_register_page.yml"
				session_hash = {"session"=>{"snippets"=>["hit_landing_page", "non_existent_snippet", "hit_register_page"]}}

				expect(File).to receive(:exist?).with(filename).and_return(true)

				expect(File).to receive(:exist?).with(snippet_1_filename).and_return(true)
				expect(File).to receive(:exist?).with(snippet_2_filename).and_return(false)

				expect(YAML).to receive(:load_file).with(filename).and_return(session_hash)
				expect(YAML).to receive(:load_file).with(snippet_1_filename).and_return({"request"=>{"name"=>"Hit Landing Page", "url"=>nil, "http_method"=>"GET"}})


				expect{
					Session.new('my_session')
				}.to raise_error ArgumentError, "No Snippet with the name 'non_existent_snippet' can be found."
			end

			it 'should load dynvars' do
				session = Session.new('dynvar_session')
				session.has_dynvars?.should be_true
				dv = session.dynvars.first
				dv.type.should == 'random_string'
			end



			it 'should load the session and component snippets' do
				session = Session.new('hit_landing_page')
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
