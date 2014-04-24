require 'spec_helper'
require 'builder'
require_relative '../lib/match'

module TsungWrapper

  describe Match do

    let(:xml)           { "" }
    let(:builder)       { Builder::XmlMarkup.new(:target => xml, :indent => 2) }

    describe '.new' do

      it 'should instantiate with the expected instance variables' do
        match = Match.new('dump_non_200_response')
        match.when.should == 'nomatch'
        match.source.should == 'all'
        match.do.should == 'dump'
        match.pattern.should == 'HTTP/1.1 200'
      end
    end


    describe '#to_xml' do
      it 'should produce the correct xml' do
        match = Match.new('dump_non_200_response')
        match.to_xml(builder)
        # puts xml 
        xml.should == %Q{<match do="dump" when="nomatch" name="dump_non_200_response">HTTP/1.1 200</match>\n}
      end
    end
  end

end


  