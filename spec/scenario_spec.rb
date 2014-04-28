require 'spec_helper'
require 'timecop'
require_relative '../lib/scenario'

module TsungWrapper

  describe Scenario do

    let(:xml)           { "" }
    let(:builder)       { Builder::XmlMarkup.new(:target => xml, :indent => 2) }
    let(:config)        { ConfigLoader.new('test') }

    describe '.new' do
      it 'should raise error if the specified name is neither a scenario nor a session' do
        expect {
          Scenario.new('missing_scenario', builder, config)
        }.to raise_error ArgumentError, "No scenario or snippet with name 'missing_scenario'."
      end

      it 'should raise error if the probabilites do not add up to 100' do
        expect {
          Scenario.new('invalid_scenario', builder, config)
        }.to raise_error RuntimeError, "The session probabilities in scenario 'invalid_scenario' do not add up to 100!"
      end



      it 'should create a scenario from a scenario file' do
        Timecop.freeze(Time.local(2014, 4, 9, 14, 3, 5)) do
          scenario = Scenario.new("my_scenario", builder, config)
          scenario.to_xml
          xml.should == scenario_xml
        end
      end


      it 'should create a scenario from a single session' do
        Timecop.freeze(Time.local(2014, 4, 9, 14, 3, 5)) do
          scenario = Scenario.new('hit_landing_page', builder, config)
          scenario.to_xml
          xml.should == hit_landing_page_scenario_xml
        end
      end
    end


  end

end



def hit_landing_page_scenario_xml
  str = <<-EOXML
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
EOXML
end





def scenario_xml
  str = <<-EOXML
<sessions>
  <session name="dynvar_session-20140409-140305" probability="20" type="ts_http">
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
  <session name="hit_landing_page-20140409-140305" probability="80" type="ts_http">
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
EOXML
end