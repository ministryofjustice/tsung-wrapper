require 'builder'
require 'yaml'

require_relative 'config_loader'
require_relative 'tsung_wrapper'
require_relative 'session'


module TsungWrapper

  class Scenario

    def initialize(scenario_or_session, builder, config)
      @builder       = builder
      @config        = config
      @sessions      = []

      filename = File.expand_path(File.join(TsungWrapper.config_dir, 'scenarios', "#{scenario_or_session}.yml"))
      if File.exist?(filename)
        session_names = YAML.load_file(filename)['scenario']
      else
        filename = File.expand_path(File.join(TsungWrapper.config_dir, 'sessions', "#{scenario_or_session}.yml"))
        unless File.exist?(filename)
          raise ArgumentError.new("No scenario or snippet with name '#{scenario_or_session}'.")
        end
        session_names = {scenario_or_session => 100 }
      end

      if session_names.values.inject{ |sum, x| sum + x } != 100
        raise RuntimeError.new "The session probabilities in scenario 'invalid_scenario' do not add up to 100!"
      end


      session_names.each { |name, probability| @sessions << Session.new(name, @builder, @config, probability) }
    end


    def to_xml
      @builder.sessions do
        @sessions.each { |session| session.to_xml }
      end
    end


    def file_dynvars
      @sessions.map(&:file_dynvars).flatten.uniq
    end

  end
end
    