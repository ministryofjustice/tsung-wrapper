require_relative '../spec_helper'
require_relative '../../lib/wrapper'
# require_relative '../lib/wrap'

module TsungWrapper

	describe "command line utility" do 

		let(:wrap)  { "ruby #{TsungWrapper.root}/lib/wrap.rb" }

		it 'should return error message if  no session is specified' do
			output = capture_stdout("#{wrap} -e test 2>&1")
			output.first.should == "Error: No session name specified\n"
		end		

		it 'should return error message if non_existent session specified' do 
			output = capture_stdout("#{wrap} -e test missing_session 2>&1")
			output.first.should == "ArgumentError: No scenario or snippet with name 'missing_session'.\n"
		end

		it 'should return error message if non-existent env specified' do 
			output = capture_stdout("#{wrap} -p lpa -e fantasy hit_landing_page  2>&1")
			output.first.should == "ArgumentError: Configuration file for environment 'fantasy' does not exist.\n"
		end
			

		it 'should print the xml file' do
			output = capture_stdout("#{wrap} -xe test hit_landing_page")
			output.first.should =~ /^<\?xml version=\"1\.0\" encoding=\"UTF-8"\?>$/
		end

	end


end

def capture_stdout(command)
	pipe = IO.popen(command)
	output = pipe.readlines
	pipe.close
	output
end
