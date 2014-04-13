require 'spec_helper'
require 'timecop'
require 'cgi'
require_relative '../lib/wrapper'

module TsungWrapper

  describe Wrapper do

    describe 'wrap' do

      it 'should raise an exception if the session cannot be found' do
        expect {
          Wrapper.new('missing sesssion', 'test')
        }.to raise_error ArgumentError, "No session found with name 'missing sesssion'"
      end



      it 'should produce a skeleton xml file if given nothing to wrap' do
        Timecop.freeze(Time.new(2014, 4, 9, 14, 3, 5)) do
          expected = simple_session
          wrapper = Wrapper.new('hit_landing_page', 'test')
          actual = wrapper.wrap
          # puts "++++++ expected ++++++ #{__FILE__}::#__LINE__)} ++++\n"
          # puts expected
          # puts "++++++ actual ++++++ #{__FILE__}::#__LINE__)} ++++\n"
          # puts actual
          actual.should == expected
        end
      end
    end

    describe '#wrap_snippet' do
      it 'should raise an exception if wrapper not instantiated through new_for_snippet' do |variable|
        wrapper = Wrapper.new('hit_landing_page', 'test')
        expect {
          wrapper.wrap_snippet
        }.to raise_error RuntimeError, "Unable to call wrap_snippet on a Wrapper that wasn't instantiated using xml_for_snippet()"
      end
    end


    describe '.xml_for_snippet' do
      it 'should emit xml for the named snippet' do
        xml = Wrapper.xml_for_snippet('hit_landing_page')
        xml.should == hit_landing_page_snippet_xml
      end
    end


    context 'request with thinktime' do
      it 'should emit a request with a thinktime element' do
        xml = Wrapper.xml_for_snippet('hit_register_page_with_thinktime')
        xml.should == hit_register_page_with_thinktime_snippet_xml
      end
    end


    context 'post_request_with_parameters' do
      it 'should emit an xml snippet for a post request with parameters' do |variable|
        xml = Wrapper.xml_for_snippet('login_with_think_time')
        xml.should == login_snippet_xml
      end
    end

    context 'post_request_with_dynamic_variables' do
      it 'should emit an xml request snippet incuding a subst=true attribute' do
        xml = Wrapper.xml_for_snippet('login_using_dynvars')
        xml.should == login_using_dynvars_xml
      end
    end


    context 'dynamic variables' do
      it 'should generate snippet to define a random string' do
        xml = Wrapper.xml_for_dynvar('random_str_12', 'username')
        xml.should == random_str_12_xml
      end

      it 'should generate snippet to define a random number' do
        xml = Wrapper.xml_for_dynvar('random_number', 'user_id')
        
        xml.should == random_number_xml
      end


      it 'should generate snippet to define an erlang function' do
        xml = Wrapper.xml_for_dynvar('erlang_function', 'todaystr')
        xml.should == erlang_function_xml
      end
    end

  end
end


def login_using_dynvars_xml
  str = <<-EOXML
<!-- Login -->
<request subst="true">
  <http url="http://test_base_url.com/user/login" version="1.1" contents="email=%%_username%%%40test.com&amp;password=%%_password%%&amp;submit=Sign+in" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
end



def erlang_function_xml
  str = <<-EOXML
<setdynvars sourcetype="eval" code="fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.">
  <var name="todaystr"/>
</setdynvars>
EOXML
end


def random_number_xml
  str = <<-EOXML
<setdynvars sourcetype="random_number" start="500" end="99000">
  <var name="user_id"/>
</setdynvars>
EOXML
end



def random_str_12_xml
  str = <<-EOXML
<setdynvars sourcetype="random_string" length="12">
  <var name="username"/>
</setdynvars>
EOXML
end








def encode_params(params)
  param_pairs = []
  params.each do |key, value|
    param_pairs << "#{key}=#{CGI.escape(value)}"
  end
  param_pairs.join('&amp;')
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
<thinktime random="true" value="6"/>
<request>
  <http url="http://test_base_url.com/user/login" version="1.1" contents="#{content_string}" content_type="application/x-www-form-urlencoded" method="POST"/>
</request>
EOXML
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




def simple_session
  str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "#{TsungWrapper.dtd}">
<tsung loglevel="notice" version="1.0">
  <!-- Client Side Setup -->
  <clients>
    <client host="localhost" use_controller_vm="true" maxusers="1500"/>
  </clients>
  <!-- Server Side Setup -->
  <servers>
    <server host="test_server_host" port="80" type="tcp"/>
  </servers>
  <load>
    <!-- Scenario 1: Average Load -->
    <arrivalphase phase="1" duration="2" unit="minute">
      <users interarrival="30" unit="second"/>
    </arrivalphase>
    <!-- Scenario 2: High Load -->
    <arrivalphase phase="2" duration="2" unit="minute">
      <users interarrival="2" unit="second"/>
    </arrivalphase>
    <!-- Scenario 3: Very High Load -->
    <arrivalphase phase="3" duration="1" unit="minute">
      <users interarrival="2" unit="second"/>
    </arrivalphase>
  </load>
  <!-- Define User Agents -->
  <options>
    <option type="ts_http" name="user_agent">
      <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
      <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
    </option>
  </options>
  <sessions>
    <session name="hit_landing_page-20140409-140305" probability="100" type="ts_http">
      <!-- Hit Landing Page -->
      <request>
        <http url="http://test_base_url.com" version="1.1" method="GET"/>
      </request>
      <!-- Hit Register Page -->
      <request>
        <http url="http://test_base_url.com/user/register" version="1.1" method="GET"/>
      </request>
    </session>
  </sessions>
</tsung>
EOXML
end




