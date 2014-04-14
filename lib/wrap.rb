# command line script to wrap session configuration files to produce Tsung XML configs

require 'optparse'
require 'tempfile'
require 'yaml'
require 'erb'

require_relative 'tsung_wrapper'
require_relative 'wrapper'

# default options
# options = {:env => 'development', :output => :xml}
options = {:env => 'development', :output => :xml, :verbose => false, :clean => nil }

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

	opts.on("-c" "--clean-log-dir HOURS", "Clean log dir of directories created before N hours ago") do |c|
		options[:clean] = HOURS.to_i
end.parse!


puts "++++++ env #{options[:env].inspect }++++++ #{__FILE__}::#{__LINE__} ++++\n"

TsungWrapper.env = options[:env]

puts "++++++ now env #{TsungWrapper.env} ++++++ #{__FILE__}::#{__LINE__} ++++\n"


filename = File.expand_path(File.join(TsungWrapper.config_dir, 'tsung.yml'))
unless File.exist?(filename)
	$stderr.puts "Unable to find config file #{filename}"
	exit 2
end


config = YAML.load(ERB.new(File.read(filename)).result)['tsung_config']
mandatory_config_keys = %w{ log_dir tsung_stats perl_libs }
mandatory_config_keys.each do |key|
	unless config.has_key?(key)
		puts $stderr.puts "Config file does not have entry for mandatory key '#{key}'."
		exit 2
	end
end

require 'pp'
pp config
exit 1



@verbose = options[:verbose]
if @verbose
	puts "Options: #{options.inspect}"
	puts "ARGS:    #{ARGV.inspect}"
end

if ARGV.empty?
	$stderr.puts "No session name specified" if ARGV.empty?
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
	$stderr.puts "#{err.class}: #{err.message}"
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


end












