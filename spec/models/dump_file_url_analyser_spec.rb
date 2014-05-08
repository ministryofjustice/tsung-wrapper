require_relative '../spec_helper'
require_relative '../../lib/dump_file_url_analyser'
module TsungWrapper

  describe DumpFileUrlAnalyser do

    let(:dfua)   { dfua = DumpFileUrlAnalyser.new(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump.csv')) }

    describe 'private method normalise_url' do
      it 'should normalise as expected' do
        dfua.send(:normalise_url, '/activate/12254577').should == '/activate'
        dfua.send(:normalise_url, '/?autoTestKey=abdjskkdhjfhf').should == ''
        dfua.send(:normalise_url, '/').should == ''
        dfua.send(:normalise_url, '/create/donor/').should == '/create/donor'
        dfua.send(:normalise_url, '/create/donor/?add=kkdj').should == '/create/donor'
        dfua.send(:normalise_url, '/create/donor?add=kkdj').should == '/create/donor'
      end
    end


    describe '#run' do
      it 'should analyse the file and produce the expected results' do
        dfua.run
        fp = File.new(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump_urls.csv'))
        puts fp.read
        fp.close
        
      end
    end

  end

end