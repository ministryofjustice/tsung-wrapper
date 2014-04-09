require 'spec_helper'
require_relative '../lib/wrapper'

module TsungWrapper

  describe Wrapper do

    describe 'wrap' do

      it 'should raise an exception if the session cannot be found' do

      end



      it 'should produce a skeleton xml file if given nothing to wrap' do
        expected = empty_xml

        

        actual = Wrapper.new('hit_landing_page', 'test').wrap

        # puts "++++++ expected ++++++ #{__FILE__}::#__LINE__)} ++++\n"
        # puts expected
        # puts "++++++ actual ++++++ #{__FILE__}::#__LINE__)} ++++\n"
        # puts actual
        
        actual.should == expected
      end

    end
  end
end





def empty_xml
  str = <<-EOXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tsung SYSTEM "#{TsungWrapper.dtd}">
<tsung loglevel="notice" version="1.0">
  <!-- Client Side Setup -->
  <clients>
    <client host="localhost" use_controller_vm="true" maxusers="40"/>
  </clients>
  <!-- Server Side Setup -->
  <servers>
    <server host="test_server_host" port="8080" type="tcp"/>
  </servers>
  <load>
    <!-- Scenario 1: Average Load -->
    <arrivalphase phase="1" duration="10" unit="minute">
      <users interarrival="30" unit="second"/>
    </arrivalphase>
    <!-- Scenario 2: High Load -->
    <arrivalphase phase="2" duration="10" unit="minute">
      <users interarrival="10" unit="second"/>
    </arrivalphase>
    <!-- Scenario 3: Very High Load -->
    <arrivalphase phase="3" duration="5" unit="minute">
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
</tsung>
EOXML
end




