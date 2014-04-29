require 'spec_helper'
require 'timecop'
require 'cgi'
require_relative '../lib/wrapper'

module TsungWrapper
  include TsungWrapperSpecHelper

  describe Wrapper do

    describe 'wrap' do

      it 'should raise an exception if the session cannot be found' do
        expect {
          Wrapper.new('missing sesssion', 'test')
        }.to raise_error ArgumentError, "No scenario or snippet with name 'missing sesssion'."
      end



      it 'should produce a skeleton xml file if given nothing to wrap' do
        Timecop.freeze(Time.new(2014, 4, 9, 14, 3, 5)) do
          expected = simple_session
          wrapper = Wrapper.new('hit_landing_page', 'test')
          actual = wrapper.wrap
          dump_to_file(actual, 'actual')
          dump_to_file(expected, 'expected')
          actual.should == expected
        end
      end


      it 'should produce a full xml file' do
        Timecop.freeze(Time.new(2014, 4, 9, 14, 3, 5)) do
          expected = session_with_dynvar
          wrapper = Wrapper.new('dynvar_session', 'test')
          actual = wrapper.wrap
          actual.should == expected
        end
      end


      it 'should produce an xml file with file_dynvar options' do
        Timecop.freeze(Time.new(2014, 4, 9, 14, 3, 5)) do
          expected = session_with_file_dynvar
          wrapper = Wrapper.new('file_dynvar_session', 'test')
          wrapper.wrap.should == expected
          dump_to_file(wrapper.wrap, 'actual')
        end
      end
    end


    describe '#register load_profile' do
      it 'should produce a simple xml file with updated arrival phases' do
        Timecop.freeze(Time.new(2014, 4, 9, 14, 3, 5)) do
          expected = simple_session_minimal_load
          wrapper = Wrapper.new('hit_landing_page', 'test')
          wrapper.register_load_profile('minimal')
          actual = wrapper.wrap
          actual.should == expected
        end
      end
    end

  end
end


def session_with_file_dynvar
  str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "/Users/stephen/src/tsung-wrapper/spec/config/tsung-1.0.dtd">
<tsung loglevel="notice" dumptraffic="false" version="1.0">
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
  <options>
    <option name="file_server" id="7c9d170598b5f52c4b9dc1b272c7ef38" value="/Users/stephen/src/tsung-wrapper/spec/config/data/username.csv"/>
    <!-- Define User Agents -->
    <option type="ts_http" name="user_agent">
      <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
      <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
    </option>
  </options>
  <sessions>
    <session name="file_dynvar_session-20140409-140305" probability="100" type="ts_http">
      <setdynvars sourcetype="file" fileid="7c9d170598b5f52c4b9dc1b272c7ef38" delimiter="," order="iter">
        <var name="username"/>
      </setdynvars>
      <setdynvars sourcetype="file" fileid="7c9d170598b5f52c4b9dc1b272c7ef38" delimiter="," order="iter">
        <var name="password"/>
      </setdynvars>
      <setdynvars sourcetype="eval" code="fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.">
        <var name="today"/>
      </setdynvars>
      <!-- Hit Landing Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com" version="1.1" method="GET"/>
      </request>
      <!-- Login -->
      <request subst="true">
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com/user/login" version="1.1" contents="email=%%_username%%%40test.com&amp;password=%%_password%%&amp;submit=Sign+in" content_type="application/x-www-form-urlencoded" method="POST"/>
      </request>
    </session>
  </sessions>
</tsung>
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



def simple_session_minimal_load
  str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "#{TsungWrapper.dtd}">
<tsung loglevel="notice" dumptraffic="false" version="1.0">
  <!-- Client Side Setup -->
  <clients>
    <client host="localhost" use_controller_vm="true" maxusers="1500"/>
  </clients>
  <!-- Server Side Setup -->
  <servers>
    <server host="test_server_host" port="80" type="tcp"/>
  </servers>
  <load>
    <!-- Scenario 1: Minimal Load -->
    <arrivalphase phase="1" duration="30" unit="second">
      <users interarrival="5" unit="second"/>
    </arrivalphase>
  </load>
  <options>
    <!-- Define User Agents -->
    <option type="ts_http" name="user_agent">
      <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
      <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
    </option>
  </options>
  <sessions>
    <session name="hit_landing_page-20140409-140305" probability="100" type="ts_http">
      <!-- Hit Landing Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com" version="1.1" method="GET"/>
      </request>
      <!-- Hit Register Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com/user/register" version="1.1" method="GET"/>
      </request>
    </session>
  </sessions>
</tsung>
EOXML
end



def simple_session
  str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "#{TsungWrapper.dtd}">
<tsung loglevel="notice" dumptraffic="false" version="1.0">
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
  <options>
    <!-- Define User Agents -->
    <option type="ts_http" name="user_agent">
      <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
      <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
    </option>
  </options>
  <sessions>
    <session name="hit_landing_page-20140409-140305" probability="100" type="ts_http">
      <!-- Hit Landing Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com" version="1.1" method="GET"/>
      </request>
      <!-- Hit Register Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com/user/register" version="1.1" method="GET"/>
      </request>
    </session>
  </sessions>
</tsung>
EOXML
end


def session_with_dynvar
str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "#{TsungWrapper.dtd}">
<tsung loglevel="notice" dumptraffic="false" version="1.0">
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
  <options>
    <!-- Define User Agents -->
    <option type="ts_http" name="user_agent">
      <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
      <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
    </option>
  </options>
  <sessions>
    <session name="dynvar_session-20140409-140305" probability="100" type="ts_http">
      <setdynvars sourcetype="random_string" length="12">
        <var name="username"/>
      </setdynvars>
      <setdynvars sourcetype="random_number" start="500" end="99000">
        <var name="userid"/>
      </setdynvars>
      <setdynvars sourcetype="eval" code="fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.">
        <var name="today"/>
      </setdynvars>
      <!-- Hit Landing Page -->
      <request>
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com" version="1.1" method="GET"/>
      </request>
      <!-- Login -->
      <request subst="true">
        <match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>
        <match do="continue" when="match" name="match_200_response">HTTP/1.1 200</match>
        <http url="http://test_base_url.com/user/login" version="1.1" contents="email=%%_username%%%40test.com&amp;password=%%_password%%&amp;submit=Sign+in" content_type="application/x-www-form-urlencoded" method="POST"/>
      </request>
    </session>
  </sessions>
</tsung>
EOXML
end
