# command line script to wrap session configuration files to produce Tsung XML configs

require 'optparse'
require File.dirname(__FILE__) + '/wrapper'

# default options
# options = {:env => 'development', :output => :xml}
options = {:env => 'development', :outut => :xml }

OptionParser.new do |opts|
	opts.banner = "Usage: wrap [-e <environment>] -x|-r session_name"
	opts.separator ""
  opts.separator "Generate Tsung XML file for session <session_name>"
  opts.separator ""

	opts.on("-e", "--environment  ENV", 'Use specified environment (default: development)') do |env|
		options[:env] = env
	end

	opts.on("-x", "--xml-out", "Generate XML config and write to STDOUT") do |xml|
		options[:output] = :xml
	end

	opts.on("-r", "--run-tsung", "Generate XML config and pipe into tsung") do |xml|
		optons[:output] = :tsung
	end
end.parse!


if ARGV.empty?
	puts "No session name specified" if ARGV.empty?
	exit(1)
end
session_name = ARGV.first

output = ""
begin
	wrapper = TsungWrapper::Wrapper.new(session_name, options[:env])
	output = wrapper.wrap
rescue => err
	puts "#{err.class}: #{err.message}"
	exit 2
end

if options[:output] == :xml 
	puts output
else
	file = Tempfile.new("tsung_wrapper_xml")
	file.puts(output)
	file.close

	# cat simple_test.xml | tsung -f - start
  %x{ cat #{file.path} | tsung -f - start } }
end















