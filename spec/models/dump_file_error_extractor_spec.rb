require_relative '../spec_helper'
require_relative '../../lib/dump_file_error_extractor'

module TsungWrapper

  describe DumpFileErrorExtractor do

    describe 'privzgte method format_ofile_name' do
      it 'should replace csv with errors.csv' do
        filename = File.join(TsungWrapper.config_dir, 'data', 'username_a.csv')
        dfee = DumpFileErrorExtractor.new(filename)
        dfee.send(:format_ofile_name, filename).should == File.join(TsungWrapper.config_dir, 'data', 'username_a_errors.csv')
      end

      it 'should add _errors.csv if the original filename does not end in .csv' do
        filename = File.join(TsungWrapper.config_dir, 'data', 'tsung.dump')
        dfee = DumpFileErrorExtractor.new(filename)
        dfee.send(:format_ofile_name, filename).should == File.join(TsungWrapper.config_dir, 'data', 'tsung.dump_errors.csv')
      end

    end

  end

end