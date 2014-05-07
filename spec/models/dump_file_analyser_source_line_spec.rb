require_relative '../spec_helper'
require_relative '../../lib/dump_file_analyser'

module TsungWrapper

  describe DumpFileAnalyser::SourceLine do

    it 'should be ok' do
      sl = DumpFileAnalyser::SourceLine.new('1398962662.958361;<0.100.0>;7;get;staging-lpa.service.dsd.io;/;200;13110;190.190;-;;;')
      sl.timestamp.should   == 1398962662.958361
      sl.client_id.should   == 7
      sl.http_verb.should   == 'get'
      sl.server.should      == 'staging-lpa.service.dsd.io'
      sl.url.should         == '/'
      sl.http_status.should == '200'
      sl.size.should        == 13110
      sl.duration.should    == 190.19
    end

  end

end


