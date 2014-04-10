require 'spec_helper'
require_relative '../lib/snippet'

module TsungWrapper

	describe Snippet do

		describe '.new' do
			it 'should raise an exception if the snippet file doesnt exist' do
				expect {
					Snippet.new('missing_snippet')
				}.to raise_error ArgumentError, "No Snippet with the name 'missing_snippet' can be found."

		end

		describe 'method missing'  do
			it 'should return the values if they exist' do
				snippet = Snippet.new("login_with_think_time")
				snippet.thinktime.should == 6
			end
		end
	end

end
