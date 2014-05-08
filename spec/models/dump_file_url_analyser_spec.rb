require_relative '../spec_helper'
require_relative '../../lib/dump_file_url_analyser'
module TsungWrapper

  describe DumpFileUrlAnalyser do

    let(:dfua)   { dfua = DumpFileUrlAnalyser.new(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump.csv')) }

    describe 'private method normalise_url' do
      it 'should normalise as expected' do
        dfua.send(:normalise_url, '/activate/12254577').should == '/activate'
        dfua.send(:normalise_url, '/?autoTestKey=abdjskkdhjfhf').should == '/'
        dfua.send(:normalise_url, '/').should == '/'
        dfua.send(:normalise_url, '/create/donor/').should == '/create/donor'
        dfua.send(:normalise_url, '/create/donor/?add=kkdj').should == '/create/donor'
        dfua.send(:normalise_url, '/create/donor?add=kkdj').should == '/create/donor'
      end
    end


    describe '#run' do
      it 'should analyse the file and produce the expected results' do
        dfua.run
        fp = File.open(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump_urls.csv'))
        actual = fp.read
        fp.close

        actual.should == expected_CSV_ouput
        
      end
    end

  end

end




def expected_CSV_ouput
  str = <<-EOS
url,num_requests,avg,min,max,max_elapsed,200,302,402,500,502
/,13,196.81,179.692,238.42,0,13,0,0,0,0
/activate,4,188.5,177.228,198.338,9,2,1,1,0,0
/add/donor,5,198.66,187.255,220.488,7,5,0,0,0,0
/create/donor,6,200.98,188.18,232.449,14,4,0,0,1,1
EOS
end