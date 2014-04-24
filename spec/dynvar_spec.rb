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
				dynvar.attr_hash.should == {:sourcetype => 'eval', :code => expected_erlang_code.chomp.to_sym}
			end

		end


		describe '#to_xml' do
			
			let(:xml)						{ "" }
			let(:builder)      	{ Builder::XmlMarkup.new(:target => xml, :indent => 2) }


			it 'should generate snippet to define a random number' do
				dynvar = Dynvar.new('random_number', 'user_id')
				dynvar.to_xml(builder)
        xml.should == random_number_xml
      end


      it 'should generate snippet to define an erlang function' do
      	dynvar = Dynvar.new('erlang_function', 'todaystr')
				dynvar.to_xml(builder)
        xml.should == erlang_function_xml
      end


      it 'should generate snippet to define a random string' do
      	dynvar = Dynvar.new('random_str_12', 'username')
				dynvar.to_xml(builder)
        xml.should == random_str_12_xml
      end


		end
	end
end



def random_str_12_xml
  str = <<-EOXML
<setdynvars sourcetype="random_string" length="12">
  <var name="username"/>
</setdynvars>
EOXML
end



def erlang_function_xml
  str = <<-EOXML
<setdynvars sourcetype="eval" code="fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.">
  <var name="todaystr"/>
</setdynvars>
EOXML
end



def random_number_xml
  str = <<-EOXML
<setdynvars sourcetype="random_number" start="500" end="99000">
  <var name="user_id"/>
</setdynvars>
EOXML
end





def expected_erlang_code
	str = <<-EOS
fun({Pid,DynVars})->
       {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
       DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
       lists:flatten(DateAsString) end.
EOS
end

