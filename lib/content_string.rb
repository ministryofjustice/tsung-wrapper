require 'cgi'


module TsungWrapper


  # This class ensures that the parameters are correctly encoded into a content string.
  # If there are substitable parameters, they must NOT be encoded, and the whole thing 
  # is returned as a symbol to prevent Builder::XmlMarkup for encoding them again.
  class ContentString

    @@dynvar_pattern = /%%_.*?%%/


    def self.encode(params)
      content_string = ContentString.new(params)
      content_string.encode
    end


    def initialize(params)
      @params = params
      @result = nil
    end


    def encode
      param_pairs = []
      @params.each do |param_name, param_value|
        param_pairs << "#{CGI.escape(param_name)}=#{encode_value(param_value)}"
      end
      result = param_pairs.join("&amp;").to_sym
    end


    private

    # extract any dynvars, escape, and then reinsert the dynvars
    def encode_value(param_value)
      substitutions = {}
      param_value = param_value.to_s
      matches = param_value.scan(@@dynvar_pattern)

      matches.each_with_index do |match, i|
        key = "__TW__SUB__#{i}"
        substitutions[key] = match
        param_value.sub!(@@dynvar_pattern, key)
      end

      param_value = CGI.escape(param_value)

      substitutions.each do |key, value|
        param_value.sub!(key, value)
      end
      param_value
    end

  end

end


