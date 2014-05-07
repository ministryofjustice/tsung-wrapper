require_relative '../spec_helper'
require_relative '../../lib/dump_file_analyser'

module TsungWrapper

  describe DumpFileAnalyser::SummaryLine do

    let(:lines)   {
          [
            "1398962662.309014;<0.94.0>;1;get;staging-lpa.service.dsd.io;/;200;13118;238.420;-;;;",
            "1398962662.958361;<0.100.0>;7;get;staging-lpa.service.dsd.io;/;302;13110;190.190;-;;;",
            "1398962663.912503;<0.98.0>;5;get;staging-lpa.service.dsd.io;/;200;13118;202.328;-;;;"
         ]
    }

    describe '.new' do
      it 'should intialize values' do
        sl = DumpFileAnalyser::SummaryLine.new(25, 5)

        sl.elapsed_time.should       == 25
        sl.interval.should           == 5
        sl.num_requests.should       == 0
        sl.max_request_time.should   == 0.0
        sl.min_request_time.should   == 99999999.99
        sl.avg_request_time.should   == nil
        sl.status_code_counts.should == {}
      end
    end


    describe '#add_source' do
      it 'should increment the variables' do
        line = DumpFileAnalyser::SourceLine.new('1398962662.958361;<0.100.0>;7;get;staging-lpa.service.dsd.io;/;200;13110;190.190;-;;;')
        sl = DumpFileAnalyser::SummaryLine.new(25, 5)
        sl.add_source(line)

        sl.elapsed_time.should       == 25
        sl.interval.should           == 5
        sl.num_requests.should       == 1
        sl.max_request_time.should   == 190.19
        sl.min_request_time.should   == 190.19
        sl.avg_request_time.should   == nil
        sl.status_code_counts.should == {'200' => 1}
      end


      it 'should maintin mins and max values and https status code counts' do 
        sl = DumpFileAnalyser::SummaryLine.new(25, 5)
        lines.each { |line| sl.add_source(DumpFileAnalyser::SourceLine.new(line) ) }

        sl.elapsed_time.should       == 25
        sl.interval.should           == 5
        sl.num_requests.should       == 3
        sl.min_request_time.should   == 190.19
        sl.max_request_time.should   == 238.42
        sl.avg_request_time.should   == nil
        sl.status_code_counts.should == {'200' => 2, '302' => 1}
        sl.http_status_codes.should  == [ '200', '302' ]
      end
    end


    describe '#finalise' do
      it 'should summarize values and return itself' do
        sl = DumpFileAnalyser::SummaryLine.new(25, 5)
        lines.each { |line| sl.add_source(DumpFileAnalyser::SourceLine.new(line) ) }
        final = sl.finalise

        final.should be_instance_of(DumpFileAnalyser::SummaryLine)
        final.elapsed_time.should             == 25
        final.interval.should                 == 5
        final.num_requests.should             == 3
        final.min_request_time.should         == 190.19
        final.max_request_time.should         == 238.42
        final.avg_request_time.should         == 210.3127
        final.num_requests_per_second.should  == 1.6667
        final.status_code_counts.should       == {'200' => 2, '302' => 1}
      end
    end

  end

end

