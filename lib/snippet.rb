require 'ostruct'
require 'cgi'

require_relative 'content_string'


module TsungWrapper

	class Snippet

		attr_reader :extract_dynvars

		def initialize(snippet_name, builder, config)
			filename = "#{TsungWrapper.config_dir}/snippets/#{snippet_name}.yml"
			unless File.exist?(filename)
				raise ArgumentError.new("No Snippet with the name '#{snippet_name}' can be found.")
			end
			@config          = config
			@builder         = builder
			snippet          = YAML.load_file(filename)
			@attrs           = snippet['request']
			@http_method     = @attrs['http_method']
			@params          = @attrs['params'].nil? ? {} : @attrs['params']
			@extract_dynvars = @attrs['extract_dynvars'].nil? ? {} :  @attrs['extract_dynvars']
			@url_dynvar      = false
			@has_dynvars     = params_contain_dynvars? || url_contains_dynvars?
			@matches         = []
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


		def method_missing(meth)
			stringified_meth = meth.to_s
			@attrs.has_key?(stringified_meth) ? @attrs[stringified_meth] : super
		end


		def matches
			if @matches.empty?
				if @attrs['matches']
					@attrs['matches'].each do |match|
						filename = File.join(TsungWrapper.config_dir, 'matches', "#{match}.yml")
						config = YAML.load_file(filename)
						struct =  OpenStruct.new(config['match'])
						struct.name = match
						@matches << struct
					end
				end
			end
			@matches
		end

		private


		def add_matches(matches)
			matches.each do |match| 
				@builder.match(match.pattern, :do => match.do, :when => match.when, :name => match.name)
			end
		end



		def generate_http_with_params
			@builder.http(:url => make_url(@config, self), 
												:version => @config.http_version, 
												:contents => self.content_string,
												:content_type => "application/x-www-form-urlencoded",
												:method => self.http_method)
		end


		def generate_http_without_params
			@builder.http(:url => make_url(@config, self), :version => @config.http_version, :method => self.http_method)
		end



		def generate_thinktimes
			if self.has_attribute?('thinktime')
				@builder.thinktime(:random => true, :value => self.thinktime)
			else
				@builder.thinktime(:random => true, :value => @config.default_thinktime)
			end
		end







		# makes the url from the snippet and the config
		# if the snippet url is a dynvar, than it is not appended to the base_url
		def make_url(config, snippet)
			url = nil
			if snippet.url.nil?
				url = config.base_url
			elsif snippet.has_url_dynvar?
				url = snippet.url
			else
				protocol, resource = config.base_url.split('://')
				resource = resource + '/' + snippet.url
				url = protocol + '://' + resource.gsub('//', '/')
			end

			# now add params if it's a get request and has params
			
			if snippet.is_get? && snippet.has_params?
				params = snippet.content_string.to_s.gsub('%2B', '+')
				url = url + '/' unless url =~ /\/$/
				url = url + '?' + params
			end
			url
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
			result = true if param_value =~ /%%_.*?%%/ 				# question mark after asterisk to stop it tbeing greedy
			result
		end
	end

end