# command line script to wrap session configuration files to produce Tsung XML configs

require 'optparse'
require 'tempfile'
require File.dirname(__FILE__) + '/wrapper'

# default options
# options = {:env => 'development', :output => :xml}
options = {:env => 'development', :output => :xml, :verbose => false }

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
		options[:output] = :tsung
	end

	opts.on("-v", "--verbose", "Set verbose mode ON") do |v|
		options[:verbose] = true
	end
end.parse!

@verbose = options[:verbose]
if @verbose
	puts "Options: #{options.inspect}"
	puts "ARGS:    #{ARGV.inspect}"
end

if ARGV.empty?
	puts "No session name specified" if ARGV.empty?
	exit(1)
end
session_name = ARGV.first

output = ""
begin
	if @verbose
		puts "Calling TsungWrapper::Wrapper.new(#{session_name}, #{options[:env]})"
	end


	wrapper = TsungWrapper::Wrapper.new(session_name, options[:env])
	output = wrapper.wrap
rescue => err
	puts "#{err.class}: #{err.message}"
	exit 2
end

if options[:output] == :xml 
	puts output
else
	filename = TsungWrapper.tmpfilename
	File.open(filename, 'w') do |fp|	
		fp.puts(output)
	end

	command = "tsung -f #{filename} start "
	if @verbose
		puts "Running commnad: #{command}"
	end

	pipe = IO.popen(command)
	while !pipe.eof do
		line = pipe.readline
		puts "Data returned from Tsung >>> #{line}"
	end
	pipe.close
	
end















