module TsungWrapper


  # This class will url-escape the content string, where parameters are posted to the form.  Normally,
  # everything passed to Builder::XmlMarkup is automatically escapted, but we don't want to do that 
  # for the content string because the might contain dynamic variable substitution strings in the form
  # %%_paramname%%, and these must not be escapec.  So this class will escape the rest of the string, 
  # and then return the result as symbol, which will prevent Builder from escaping it again.
  #
  class ContentStringEncoder


    def self.encode(string)
      encoder = ContentStringEncoder.new(string)
      encoder.encode
    end

    def initialize(string)
      @original_string = string
      @substitutions   = {}
      @regex           = /%%_.*?%%/
    end


    def encode
      # firstly substitute all the matching pattersn with __TS_SUB_n
      matches = @original_string.scan(@regex)
      matches.each_with_index do |match, i|
        key = "__TW__SUB__#{i}"
        @substitutions[key] = match
        @original_string.sub!(@regex, key)
      end

      # now encode the original string
      @original_string = CGI.escape(@original_string)

      # now replace the original matches
      @substitutions.each do |key, value|
        @original_string.sub!(key, value)
      end

      # now make sure special characters are correctly escape

      @original_string.to_sym
    end

  end

end