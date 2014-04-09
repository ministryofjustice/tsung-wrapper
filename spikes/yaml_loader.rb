require 'yaml'
require 'awesome_print'
require 'pp'

filename = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'sessions', 'hit_landing_page.yml'))

config = YAML.load_file(filename)

ap config, plain: true

puts "++++++ DEBUG ++++++ #{__FILE__}::#__LINE__)} ++++\n"


pp config