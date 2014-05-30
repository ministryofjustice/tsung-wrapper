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

	# helper method to output actual and expected to files in ~/tmp so diffmerge can be used to compare them
	def diffmerge(actual, expected)
	  home = ENV['HOME']
	  File.open(File.join(home, 'tmp', 'actual.html'), 'w') do |fp|
	    fp.print actual
	  end
	  File.open(File.join(home, 'tmp', 'expected.html'), 'w') do |fp|
	    fp.print expected
	  end
	  puts "**** HTML written to actual.html and expected.html in #{home}/tmp for comparison in diffmerge"
	end
end


RSpec.configure do |c|
  c.include TsungWrapperSpecHelper
end
