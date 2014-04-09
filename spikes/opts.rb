require 'optparse'
require 'pp'


# default options
# options = {:env => 'development', :output => :xml}
options = {:env => 'development', :outut => :xml }
# OptionParser.new do |opts|
#   opts.banner = "Usage: example.rb [options]"

#   opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#     options[:verbose] = v
#   end
# end.parse!


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


p options
p ARGV




