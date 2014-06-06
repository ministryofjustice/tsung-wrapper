require 'ostruct'
require 'cgi'

require_relative 'content_string'
require_relative 'match'
require_relative 'config_loader'


module TsungWrapper

  class Snippet

    attr_reader :extract_dynvars, :matches, :config, :url

    def initialize(snippet_name, builder, config)
      filename = "#{TsungWrapper.config_dir}/snippets/#{snippet_name}.yml"
      unless File.exist?(filename)
        raise ArgumentError.new("No Snippet with the name '#{snippet_name}' can be found.")
      end
      @config          = config
      @builder         = builder
      snippet          = YAML.load_file(filename)
      @attrs           = snippet['request']
      @url             = @attrs['url']
      @http_method     = @attrs['http_method']
      @params          = @attrs['params'].nil? ? {} : @attrs['params']
      @extract_dynvars = @attrs['extract_dynvars'].nil? ? {} :  @attrs['extract_dynvars']
      @url_dynvar      = false
      @has_dynvars     = params_contain_dynvars? || url_contains_dynvars?
      @matches         = load_matches
    end


    def to_xml
      @builder.comment! self.name
      generate_thinktimes unless @config.ignore_thinktimes?
      request_attrs = self.has_dynvars? ? {:subst => true} : nil

      @builder.request(request_attrs) do 
        add_matches(self.matches)
        add_extract_dynvars(self) if self.has_extract_dynvars?
        if self.is_post? && self.has_params?
          generate_http_with_params
        else
          generate_http_without_params
        end
      end
    end


    # returns true if the environment config specifies basic auth and the snippet says use_basic_auth
    def http_basic_auth?
      @config.http_basic_auth?
    end


    # generates the content string to be submitted for parameters, something like:
    #
    #  :'email=test%40test.com&amp;password=Abc123123&submit=Sign+in'
    #
    # The is returned as a symbol to prevent Builder::XmlMarkup url-escaping it again.
    # We take care of the url escaping here rather than leaveing it to Builder becuase dynvar 
    # names have the pattern %%_paramname%%, and so must be excluded from the url escaping
    #
    def content_string
      ContentString.encode(@params)
    end


    def has_dynvars?
      @has_dynvars
    end


    def has_url_dynvar?
      @url_dynvar
    end


    # we want to return nil
    def has_attribute?(attr_name)
      @attrs.has_key?(attr_name)
    end

    def has_params?
      @params.any?
    end


    def has_extract_dynvars?
      @extract_dynvars.any?
    end

    def is_get?
      @http_method == 'GET'
    end

    def is_post?
      @http_method  == 'POST'
    end


    # returns the keys of the params that are stored
    def params
      @params.keys
    end

    def param(key)
      @params.has_key?(key) ? CGI.escape(@params[key]) : nil
    end


    def method_missing(*meth_and_params)
      meth = meth_and_params.first
      stringified_meth = meth.to_s
      @attrs.has_key?(stringified_meth) ? @attrs[stringified_meth] : super
    end

    
    private

    # loads the matches from the snippet definition, or the default matches if there aren't any defined in the snippet
    def load_matches
      matches = []
      if @attrs['matches']
        @attrs['matches'].each { |match_name| matches << Match.new(match_name) }
      end
      matches = @config.default_matches if matches.empty?
      matches
    end




    def add_matches(matches)
      matches.each do |match| 
        @builder.match(match.pattern, :do => match.do, :when => match.when, :name => match.name)
      end
    end



    def generate_http_with_params
      @builder.http(:url => make_url, 
                        :version => @config.http_version, 
                        :contents => self.content_string,
                        :content_type => "application/x-www-form-urlencoded",
                        :method => self.http_method) do
        add_basic_auth                    
      end
    end


    def generate_http_without_params
      @builder.http(:url => make_url, :version => @config.http_version, :method => self.http_method) do
        add_basic_auth
      end
    end



    def generate_thinktimes
      if self.has_attribute?('thinktime')
        @builder.thinktime(:random => true, :value => self.thinktime)
      else
        @builder.thinktime(:random => true, :value => @config.default_thinktime)
      end
    end


    def add_basic_auth
      if http_basic_auth?
        @builder.www_authenticate(:userid => @config.username, :passwd => @config.password)
      end
    end

 
 

    # makes the url from the snippet and the config
    # if the snippet url is a dynvar, than it is not appended to the base_url
    def make_url
      made_url = nil
      if has_url_dynvar?
        made_url = @url
      else
        protocol, resource = @config.base_url_and_port.split('://')
        resource = resource + '/' + @url unless @url.blank?
        if is_get? && has_params?
          params = self.content_string.to_s.gsub('%2B', '+')
          resource = resource + '?' + params
        end
        made_url = protocol + '://' + resource.gsub(/\/+/, '/')
      end
      made_url
    end


    def add_extract_dynvars(snippet)
      snippet.extract_dynvars.keys.each do |name|
        @builder.dyn_variable(:name => name, :re => snippet.extract_dynvars[name])
      end
    end





    def url_contains_dynvars?
      @url_dynvar = contains_dynvar?(@attrs['url'])
    end

    def params_contain_dynvars?
      result = false
      @params.each do |key, value|
        if contains_dynvar?(value)
          result = true
          break
        end
      end
      result
    end


    def contains_dynvar?(param_value)
      result = false
      result = true if param_value =~ /%%_.*?%%/        # question mark after asterisk to stop it tbeing greedy
      result
    end
  end

end