require_relative '../spec_helper'

require_relative '../../lib/load_profile'

module TsungWrapper
  include TsungWrapperSpecHelper

  describe LoadProfile do

    let(:xml)           { "" }
    let(:builder)       { Builder::XmlMarkup.new(:target => xml, :indent => 2) }

    describe '#to_xml' do

      it 'should raise error if no Builder::XmlMarkup object has been supplied' do
        expect {
          p = LoadProfile.new('average').to_xml
        }.to raise_error RuntimeError, 'Must call set_xml_builder() before calling to_xml'
      end

      it 'should generate the correct xml' do
        lp = LoadProfile.new('average')
        lp.set_xml_builder(builder)
        lp.to_xml
        xml.should == average_xml
      end

      it 'should generate xml for max user arrival phase' do
        lp = LoadProfile.new('single_user')
        lp.set_xml_builder(builder)
        lp.to_xml
        xml.should == single_user_xml
      end



    end

  end

end


def single_user_xml
  str = <<-EOXML
<load>
  <!-- Scenario 1: Single User -->
  <arrivalphase phase="1" duration="6" unit="second">
    <users maxnumber="1" arrivalrate="5" unit="second"/>
  </arrivalphase>
</load>
 EOXML
end


def average_xml
  str = <<-EOXML
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
 EOXML
end