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
        dynvar.is_file_dynvar?.should be_false
			end

      context 'file_dynvar' do

        it 'should load a file_dynvar definition and produce the expected attrs' do
          dynvar = Dynvar.new('file_dynvar', 'username')
          dynvar.type.should == 'file'
          dynvar.filename.should == 'username.csv'
          dynvar.fileid.should == '7c9d170598b5f52c4b9dc1b272c7ef38'
          dynvar.order.should == 'iter'
          dynvar.delimiter.should == ","
          dynvar.varname.should == 'username'
          dynvar.is_file_dynvar?.should be_true
          dynvar.filepath.should =~ /config\/data\/username\.csv$/
        end


        it 'should load a random file_dynvar definition and produce the expected attrs' do
          dynvar = Dynvar.new('file_dynvar_random', 'username')
          dynvar.type.should == 'file'
          dynvar.filename.should == 'username.csv'
          dynvar.fileid.should == '7c9d170598b5f52c4b9dc1b272c7ef38'
          dynvar.order.should == 'random'
          dynvar.delimiter.should == ","
          dynvar.varname.should == 'username'
        end

        it 'should raise an error if the csv file doesnt exist' do
          expect {
            dynvar = Dynvar.new('file_dynvar_with_missing_csv', 'username')
          }.to raise_error ArgumentError, /^CSV file .*missing\.csv' cannot be found./
        end

        it 'should raise an error if invalid file access specified' do
          expect {
            dynvar = Dynvar.new('file_dynvar_with_invalid_file_access', 'username')
          }.to raise_error ArgumentError, 'Invalid access specified for file_dynvar'
        end
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

      it 'should generate a file_dynvar' do
        dynvar = Dynvar.new('file_dynvar', 'username')
        dynvar.to_xml(builder)
        xml.should == file_dynvars_xml
      end
		end


    context 'comparable' do

      it 'should uniq dynvars with equal fileids' do
        dynvar_1 = Dynvar.new('file_dynvar', 'username')
        dynvar_2 = Dynvar.new('file_dynvar', 'username')
        
        
        array = [ dynvar_1, dynvar_2 ]
        array.map(&:fileid).should == [ '7c9d170598b5f52c4b9dc1b272c7ef38', '7c9d170598b5f52c4b9dc1b272c7ef38' ]
        uniq_array = array.uniq
        uniq_array.size.should == 1
        uniq_array.map(&:fileid).should == [ '7c9d170598b5f52c4b9dc1b272c7ef38' ]
      end

      it 'should not unique dynvars with different filedids' do
        dynvar_1 = Dynvar.new('file_dynvar', 'username')
        dynvar_2 = Dynvar.new('file_dynvar_a', 'username')
        dynvar_3 = Dynvar.new('file_dynvar_a', 'username')
        array = [ dynvar_1, dynvar_2, dynvar_3 ]


        array.map(&:fileid).should == ["7c9d170598b5f52c4b9dc1b272c7ef38", "dd772e53dd00493a6e4013e4da48615b", "dd772e53dd00493a6e4013e4da48615b"]
        uniq_array = array.uniq
        uniq_array.size.should == 2
        uniq_array.map(&:fileid).should == ["7c9d170598b5f52c4b9dc1b272c7ef38", "dd772e53dd00493a6e4013e4da48615b" ]
      end

    end
	end
end


def file_dynvars_xml
  str = <<-EOXML
<setdynvars sourcetype="file" fileid="7c9d170598b5f52c4b9dc1b272c7ef38" delimiter="," order="iter">
  <var name="username"/>
</setdynvars>
EOXML
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

