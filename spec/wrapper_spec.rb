require 'spec_helper'
require 'timecop'
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
          wrapper.send(:wrap_snippet)
        }.to raise_error RuntimeError, "Unable to call wrap_snippet on a Wrapper that wasn't instantiated using new_for_snippet()"
      end
      
    end


  end
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




