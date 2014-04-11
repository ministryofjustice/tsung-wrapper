require 'spec_helper'
require_relative '../lib/dynvar'

module TsungWrapper

	describe Dynvar do

		describe '.new' do
			
			it 'should raise an error if the dynvar snippet doesnt exist' do
				expect {
					Dynvar.new('missing_dynvar', 'myvar')
				}.to raise_error ArgumentError, "No Dynamic Variable snippet with name 'missing_dynvar' can be found."
			end

			it 'should raise an exception if the type is invalid'  do
				expect {
					Dynvar.new('invalid_dynvar_type', 'myvar')
				}.to raise_error ArgumentError, "Invalid type 'ruby' defined in Dynamic Variable snippet."
			end


			it 'should load a random string definition and produce the expected attrs' do
				dynvar = Dynvar.new('random_str_12', 'myvar')
				dynvar.type.should == 'random_string'
				dynvar.length.should == 12
				dynvar.varname.should == 'myvar'
				dynvar.attr_hash.should == {:sourcetype => "random_string", :length => 12}
			end


			it 'should load a random number definition and produce the expected attrs' do
				dynvar = Dynvar.new('random_number', 'myvar')
				dynvar.type.should == 'random_number'
				dynvar.start.should == 500
				dynvar.end.should == 99000
				dynvar.varname.should == 'myvar'
				dynvar.attr_hash.should == {:sourcetype => 'random_number', :start => 500, :end => 99000}
			end

			it 'should load an erlang definion and produce the expected attrs' do
				dynvar = Dynvar.new('erlang_function', 'myvar')
				dynvar.type.should == 'eval'
				dynvar.code.should == expected_erlang_code
				dynvar.varname.should == 'myvar'
				dynvar.attr_hash.should == {:sourcetype => 'eval', :code => expected_erlang_code}
			end
		end
	end
end



def expected_erlang_code
	str = <<-EOS
fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.
EOS
end

