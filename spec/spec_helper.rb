require 'yaml'
require 'pp'
require 'awesome_print'

require_relative '../lib/tsung_wrapper'

TsungWrapper.env = 'test'

# require the classes you need
# Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each { |f| load(f) }

