require_relative 'tsung_wrapper'

module TsungWrapper

  # class to encapsulate either a default match for an environment, or a match specified at the snippet level
  class Match

    attr_reader :when, :source, :do, :pattern, :name

    def initialize(name)
      filename = File.join(TsungWrapper.config_dir, 'matches', "#{name}.yml")
      config   = YAML.load_file(filename)['match']
      @name    = name
      @when    = config['when'] 
      @source  = config['source']
      @do      = config['do']
      @pattern = config['pattern']
    end

    def to_xml(builder)
      builder.match(@pattern, :do => @do, :when => @when, :name => @name)
    end


  end
end

