require 'spec_helper'
require_relative '../lib/tsung_wrapper'

describe 'TsungWrapper module methods' do

	context 'env related methods' do

		let(:root)  { File.expand_path(File.dirname(__FILE__) + '/..') }

		context 'test environment' do
			it 'should return the locations for the test environment' do
				TsungWrapper.env.should == 'test'
				TsungWrapper.root.should == root
				TsungWrapper.config_dir.should == "#{root}/spec/config"
				TsungWrapper.dtd.should == "#{root}/spec/config/tsung-1.0.dtd"
			end
		end

		context 'development environment' do
			 it 'should return the locations for the dev environment' do
				allow(TsungWrapper).to receive(:env).and_return('development')
				TsungWrapper.env.should == 'development'
				TsungWrapper.root.should == root
				TsungWrapper.config_dir.should == "#{root}/config"
				TsungWrapper.dtd.should == "#{root}/config/tsung-1.0.dtd"
			end
		end

	end




	describe '.root' do
		it 'should return the full root path' do
			TsungWrapper.root.should == File.expand_path(File.join(File.dirname(__FILE__), '..'))
		end
	end


	describe '.dtd' do
		it 'should return the full path of the dtd file' do
			TsungWrapper.dtd.should == File.expand_path(File.join(File.dirname(__FILE__), 'config', 'tsung-1.0.dtd'))
		end
	end
end