require 'spec_helper'
require_relative '../lib/dump_file_analyser'

module TsungWrapper

  describe DumpFileAnalyser do

    describe '.new' do
      it 'should raise if the file doesnt exist' do
        expect {
          DumpFileAnalyser.new('missing_dump_file', 33)
        }.to raise_error ArgumentError, "File missing_dump_file does not exist"
      end

      it 'should raise if the file contains an invalid header line' do 
        expect {
          DumpFileAnalyser.new(File.join(TsungWrapper.config_dir, 'data', 'invalid_tsung.dump'), 33)
        }.to raise_error RuntimeError, %Q{Error: Unexpected first line - was it created with the dumptraffic="protocol" option?:\n>>> This isn't what I expect on the first line <<<}
      end

      it 'should intantiate an Analyser if the file exists and had a valid header line' do
        dfa = DumpFileAnalyser.new(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump'), 33)
        dfa.should be_instance_of(DumpFileAnalyser)
      end
    end


    describe '#run' do
      
      it 'should produce an output file summarised as expected' do
        dfa = DumpFileAnalyser.new(File.join(TsungWrapper.config_dir, 'data', 'tsung.dump'), 5)
        dfa.run
      end

    end


  end

end