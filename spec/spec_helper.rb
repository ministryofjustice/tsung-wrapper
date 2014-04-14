require 'simplecov'
	
SimpleCov.start do
	add_filter '_spec.rb'
end


require 'pry'
require 'yaml'
require 'pp'
require 'awesome_print'

require_relative '../lib/tsung_wrapper'

TsungWrapper.env = 'test'

# require the classes you need
# Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each { |f| load(f) }

module TsungWrapperSpecHelper

	# utility for dumping actual and expected to files in ~/tmp so that we can use diffmerge to look at the differences
	def dump_to_file(data, filename)
	  filename = "#{ENV['HOME']}/tmp/#{filename}.xml"
	  File.open(filename, 'w') do |fp|
	    fp.puts data
	  end
	end

end


RSpec.configure do |c|
  c.include TsungWrapperSpecHelper
end
