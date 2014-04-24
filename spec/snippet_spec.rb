require 'spec_helper'
require 'builder'

require_relative '../lib/snippet'
require_relative '../lib/config_loader'

module TsungWrapper
	include TsungWrapperSpecHelper

	describe Snippet do
		let(:xml)				{ "" }
		let(:builder)   { Builder::XmlMarkup.new(:target => xml, :indent => 2) }
		let(:config)		{ ConfigLoader.new('test_with_no_matches') }


		describe '#to_xml' do
			it 'should emit xml for hit landing page snippet' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.to_xml
				xml.should == hit_landing_page_snippet_xml
			end

			it 'should emit xml with a thinktime element if the environment default thinktime is not zero' do
				# Given a config with a non-zero think time	
				config.instance_variable_set(:@default_thinktime, 10)
				snippet = Snippet.new('hit_register_page_with_thinktime', builder, config)
				snippet.to_xml
				xml.should == hit_register_page_with_thinktime_snippet_xml
			end

      it 'should emit an xml snippet for a post request with parameters' do 
      	snippet = Snippet.new('login_with_think_time', builder, config)
      	snippet.to_xml
        xml.should == login_snippet_xml
      end

      it 'should emit xml with a url and params' do
      	snippet = Snippet.new('hit_landing_page_with_auto_test_key', builder, config)
      	snippet.to_xml
        xml.should == login_with_autokey_snippet_xml
      end

      it 'should emit an xml request snippet incuding a subst=true attribute' do
      	snippet = Snippet.new('login_using_dynvars', builder, config)
      	snippet.to_xml
        xml.should == login_using_dynvars_xml
      end

       it 'should generate a snippet with set_dynvars elements' do
       	snippet = Snippet.new('register_user_and_store_authurl', builder, config)
       	snippet.to_xml
        xml.should == register_user_and_store_authurl_xml
      end


      it 'should generate a request snippet including named matches' do
      	snippet = Snippet.new('login_with_dynvar_and_match_response', builder, config)
      	snippet.to_xml
        xml.should == login_with_dynvar_and_match_response_xml
      end

       it 'should generate a request where the url is a dynamic variable' do
        snippet = Snippet.new('activate_account', builder, config)
        snippet.to_xml
        xml.should == activate_account_xml
      end

      it 'should generate thinktime from the environment default if not specified in snippet' do 
        # given a config with a non-zero thinktime
        myconfig = ConfigLoader.new('test_with_thinktime')

        # and a snippet without it's own thinktimne
        snippet = Snippet.new('activate_account', builder, myconfig)

        # The gnerated xml should have the thinktime from the config        
        snippet.to_xml
        xml.should =~ /<thinktime random="true" value="8"\/>/
      end

      
		end



		describe '.new' do
			it 'should raise an exception if the snippet file doesnt exist' do
				expect {
					Snippet.new('missing_snippet', builder, config)
				}.to raise_error ArgumentError, "No Snippet with the name 'missing_snippet' can be found."
			end
		end

		describe 'method missing'  do
			let(:snippet)   { Snippet.new("login_with_think_time", builder, config) }
			
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
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.has_attribute?('thinktime').should be_true
			end

			it 'should return false if the attribute is not present' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.has_attribute?('thinktime').should be_false
			end
		end


		describe '#has_params?' do
			it 'should return true for snippets with params' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.has_params?.should be_true
			end

			it 'should return false for snippets without params' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.has_params?.should be_false
			end
		end 


		describe '#has_extract_dynvars?' do
			it 'should return false if there are no dynvars to be extracted' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.has_extract_dynvars?.should be_false
			end

			it 'should return true if dynvars are to be extracted' do
				snippet = Snippet.new('register_user_and_store_authurl', builder, config)
				snippet.has_extract_dynvars?.should be_true
			end
		end

		context 'extract dynvars' do
			it 'should return empty hash if there are no extracted dynvars' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.extract_dynvars.should == {}
			end

			it 'should return populated hash if there are extracted dynvars' do
				snippet = Snippet.new('register_user_and_store_authurl', builder, config)
				snippet.extract_dynvars.should == {
					'activationurl'				=> "id='activation_link' href='(.*)'",
					'page_title'			   	=> "&lt;title&gt;(.*)&lt;/title&gt;"
				}
			end
		end


		describe '#is_get?' do
			it 'should return true for gets' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.is_get?.should be_true
			end

			it 'should return false for posts' do
				snippet = Snippet.new('login_using_dynvars', builder, config)
				snippet.is_get?.should be_false
			end
		end


		describe '#is_post?' do
			it 'should return false for gets' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.is_post?.should be_false
			end

			it 'should return true for posts' do
				snippet = Snippet.new('login_using_dynvars', builder, config)
				snippet.is_post?.should be_true
			end
		end


		describe '#params' do
			it 'should return a list of parameter names' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.params.should == ['email', 'password', 'submit']
			end

			it 'should return an empty arry if there are no params' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.params.should == []
			end
		end


		describe '#has_dynvars?' do
			it 'should return false if there are no parameters' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.has_dynvars?.should be_false
			end

			it 'should return false if the parameters do not contains dynvars' do
				snippet = Snippet.new('login_with_random_user_name', builder, config)
				snippet.has_dynvars?.should be_false
			end

			it 'should return true if at least one param contains a dynvar' do
				snippet = Snippet.new('login_using_dynvars', builder, config)
				snippet.has_dynvars?.should be_true
			end

			it 'should return true if the url is specified as a dynvar' do
				snippet = Snippet.new('activate_account', builder, config)
				snippet.has_dynvars?.should be_true
			end
		end


		describe 'has_url_dynvar?' do
			
			it 'should return true if the url is a dynvar' do
				snippet = Snippet.new('activate_account', builder, config)
				snippet.has_url_dynvar?.should be_true
			end

			it 'should return false if the url is not a dynvar' do
				snippet = Snippet.new('login_using_dynvars', builder, config)
				snippet.has_url_dynvar?.should be_false
			end
		end


		describe '#param' do
			it 'should return the CGI encoded value of the param' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.param('email').should == 'test%40test.com'
				snippet.param('password').should == 'Abc123123'
				snippet.param('submit').should == 'Sign+in'
			end

			it 'should return nil if there is no such parameter' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.param('surname').should be_nil
			end

			it 'should return nil if there are no parameters' do
				snippet = Snippet.new('hit_landing_page', builder, config)
				snippet.param('email').should be_nil
			end
		end

		describe '#content_string' do
			it 'should return an encoded parameter string' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.content_string.should == :'email=test%40test.com&amp;password=Abc123123&amp;submit=Sign+in'
			end
		end


		describe '#matches' do
			it 'should return an empty array if there are no matches' do
				snippet = Snippet.new('login_with_think_time', builder, config)
				snippet.matches.should be_instance_of(Array)
				snippet.matches.should be_empty
			end

			it 'should return an array of OpenStructs containing match attributes' do
				snippet = Snippet.new('login_with_dynvar_and_match_response', builder, config)
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

	end

end


def hit_register_page_with_thinktime_snippet_xml
  str = <<-EOXML
<!-- Hit Register Page With Thinktime -->
<thinktime random="true" value="5"/>
<request>
  <http url="http://test_base_url.com/user/register" version="1.1" method="GET"/>
</request>
EOXML
end


def hit_landing_page_snippet_xml
  str = <<-EOXML
<!-- Hit Landing Page -->
<request>
  <http url="http://test_base_url.com" version="1.1" method="GET"/>
</request>
EOXML
end

def login_snippet_xml
  params = {
    'email'    => 'test@test.com',
    'password' => 'Abc123123',
    'submit'   => 'Sign in'
  }
  content_string = "#{encode_params(params)}"

  # params = contents='email=test3%40test.com&amp;password=Abc123123&amp;submit=Sign+in' content_type='application/x-www-form-urlencoded'
  str = <<-EOXML
<!-- Login -->
<request>
  <http url="http://test_base_url.com/user/login" version="1.1" contents="#{content_string}" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
end



def encode_params(params)
  param_pairs = []
  params.each do |key, value|
    param_pairs << "#{key}=#{CGI.escape(value)}"
  end
  param_pairs.join('&amp;')
end

def hit_register_page_with_thinktime_snippet_xml
  str = <<-EOXML
<!-- Hit Register Page With Thinktime -->
<thinktime random="true" value="5"/>
<request>
  <http url="http://test_base_url.com/user/register" version="1.1" method="GET"/>
</request>
EOXML
end


def login_with_autokey_snippet_xml
  str = <<-EOXML
<!-- Hit Landing Page With Auto Key -->
<request>
  <http url="http://test_base_url.com/?setAutoKey=I5iOAmnnQaq5JPI8JHYcdXQPlI09bQnHoeAxb7xYjTe+FLPTVHZho3zK0mu41ouPmxLXJlZYi" version="1.1" method="GET"/>
</request>
EOXML
end



def login_using_dynvars_xml
  str = <<-EOXML
<!-- Login -->
<request subst="true">
  <http url="http://test_base_url.com/user/login" version="1.1" contents="email=%%_username%%%40test.com&amp;password=%%_password%%&amp;submit=Sign+in" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
end



def register_user_and_store_authurl_xml
  str = <<-EOXML
<!-- Hit Register Page and store AuthURL from response -->
<request subst="true">
  <dyn_variable name="activationurl" re="id='activation_link' href='(.*)'"/>
  <dyn_variable name="page_title" re="&amp;lt;title&amp;gt;(.*)&amp;lt;/title&amp;gt;"/>
  <http url="http://test_base_url.com/user/register" version="1.1" contents="email=%%_username%%&amp;email_confirm=%%_username%%&amp;password=Passw0rd&amp;password_confirm=Passw0rd&amp;confirmUnderstanding=1&amp;submit=I+understand&amp;setAutoKey=I5iOAmnnQaq5JPI8JHYcdXQPlI09bQnHoeAxb7xYjTe%2BFLPTVHZho3zK0mu41ouPmxLXJlZYi" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
end



def login_with_dynvar_and_match_response_xml
  str = <<-EOXML
<!-- Login -->
<request subst="true">
  <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
  <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
  <http url="http://test_base_url.com/user/login" version="1.1" contents="email=%%_username%%%40test.com&amp;password=%%_password%%&amp;submit=Sign+in" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
end



def activate_account_xml
  str = <<-EOXML
<!-- Activate Account -->
<request subst="true">
  <http url="%%_activationurl%%" version="1.1" method="GET"/>
</request>
EOXML
end

