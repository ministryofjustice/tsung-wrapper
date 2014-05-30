require 'cgi'
require 'active_support/all'


module TsungWrapper


  # This class ensures that the parameters are correctly encoded into a content string.
  # If there are substitable parameters, they must NOT be encoded, and the whole thing 
  # is returned as a symbol to prevent Builder::XmlMarkup for encoding them again.
  # Additionally, it takes care of encoding arrays and hashes:
  #
  # * Array: ids = [1, 2, 2] => ids[]=1&ids[]=2&ids[]=3
  # * Hash:  client = { "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } } =>
  #          client[name]=Acme&client[phone]=1234&client[address][postcode]=12345&client[address][city]=Carrot City
  #
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
      string = unencode_dynvars(@params.to_query)
      string = encode_ampersands(string)
      string.to_sym
    end


    private

    def encode_ampersands(string)
      string.gsub('&', '&amp;')
    end


    # replaces multiple occurances of %25%25_dynvar_name%25%25 back to %%_dynvar_name%%
    def unencode_dynvars(string)
      match = string =~ /((%25%25_)(.*?)(%25%25))/
      while !match.nil? do
        string.sub!($1, "%%_#{$3}%%")
        match = string =~ /((%25%25_)(.*?)(%25%25))/
      end
      string
    end

  end

end


