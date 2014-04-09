require 'spec_helper'
require_relative '../lib/tsung_wrapper'

describe 'TsungWrapper module methods' do

	describe '.root' do
		it 'should return the full root path' do
			TsungWrapper.root.should == File.expand_path(File.join(File.dirname(__FILE__), '..'))
		end
	end


	describe '.dtd' do
		it 'should return the full path of the dtd file' do
			TsungWrapper.dtd.should == File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'tsung-1.0.dtd'))
		end
	end
end