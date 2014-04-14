require 'yaml'
require 'erb'
require 'awesome_print'
require 'pp'

filename = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'config', 'tsung.yml'))


text = File.read(filename)
# puts "++++++ TEXT ++++++ #{__FILE__}::#{__LINE__} ++++\n"
# puts text

# erb = ERB.new(text)
# puts "++++++ ERB ++++++ #{__FILE__}::#{__LINE__} ++++\n"

# pp erb


# config = YAML.load(erb.result)

config = YAML.load(ERB.new(File.read(filename)).result)

ap config, plain: true

puts "++++++ DEBUG ++++++ #{__FILE__}::#__LINE__)} ++++\n"


pp config