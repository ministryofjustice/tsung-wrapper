
require 'timecop'
require_relative '../spec_helper'
require_relative '../../lib/tsung_wrapper'

describe 'TsungWrapper module methods' do

	context 'env related methods' do

		let(:root)  { File.expand_path(File.dirname(__FILE__) + '/../..') }

		context 'test environment' do
			it 'should return the locations for the test environment' do
				TsungWrapper.env.should == 'test'
				TsungWrapper.root.should == root
				TsungWrapper.config_dir.should == "#{root}/spec/config"
				TsungWrapper.dtd.should == "#{root}/spec/config/tsung-1.0.dtd"
			end


			it 'test_env? and development_env? should return as expected ' do
				TsungWrapper.test_env?.should	be_true
				TsungWrapper.development_env?.should	be_false
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

			it 'test_env? and development_env? should return as expected ' do
				allow(TsungWrapper).to receive(:env).and_return('development')
				TsungWrapper.test_env?.should	be_false
				TsungWrapper.development_env?.should	be_true
			end

			it 'should set the environment to development if not already set'  do
				saved_env = ENV['TSUNG_WRAPPER_ENV']
				ENV['TSUNG_WRAPPER_ENV'] = nil
				TsungWrapper.env.should == 'development'
				ENV['TSUNG_WRAPPER_ENV'].should == 'development'
				ENV['TSUNG_WRAPPER_ENV'] = saved_env
			end
		end
	end




	describe '.root' do
		it 'should return the full root path' do
			TsungWrapper.root.should == File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
		end
	end


	describe '.dtd' do
		it 'should return the full path of the dtd file' do
			TsungWrapper.dtd.should == File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'tsung-1.0.dtd'))
		end
	end


	describe '.tmpfilename' do 
		it 'should generate a tempfile name without a seed' do 
			Timecop.freeze(Time.new(2014, 4, 10, 11, 12, 13)) do
				filename = TsungWrapper.tmpfilename
				filename.should =~ /TW-140410111213000.tmp$/
			end

			Timecop.freeze(Time.new(2014, 4, 10, 11, 12, 13)) do
				filename = TsungWrapper.tmpfilename('ABC')
				filename.should =~ /TWABC-140410111213000.tmp$/
			end
			
		end		
	end



	describe '.formatted_time' do 
		it 'should output the time is the spedified format' do 
			Timecop.freeze(Time.local(2014, 4, 28, 15, 43, 12)) do
				TsungWrapper.formatted_time.should == '20140428-154312'
			end
		end
	end

end









