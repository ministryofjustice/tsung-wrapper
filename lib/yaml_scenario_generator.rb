require 'yaml'

module TsungWrapper

  class YamlScenarioGenerator

    def initialize(scenario_hash)
      @scenario_hash = scenario_hash

      @snippet_hash = {
          'request' => {
              'name'        => scenario_hash['title'],
              'url'         => '/submission',
              'http_method' => 'POST',
              'params'      => {
                  'utf8'        => "✓",
                  'claim'       => scenario_hash[:claim]
              }
          }
      }    
    end


    def to_yaml
      @snippet_hash.to_yaml
    end

  end
end
