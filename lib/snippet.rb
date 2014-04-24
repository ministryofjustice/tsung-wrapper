require 'ostruct'
require 'cgi'

require_relative 'content_string'
require_relative 'match'
require_relative 'config_loader'


module TsungWrapper

	class Snippet

		attr_reader :extract_dynvars, :matches

		def initialize(snippet_name)
			filename = "#{TsungWrapper.config_dir}/snippets/#{snippet_name}.yml"
			unless File.exist?(filename)
				raise ArgumentError.new("No Snippet with the name '#{snippet_name}' can be found.")
			end

			config           = YAML.load_file(filename)
			@attrs           = config['request']
			@http_method 		 = @attrs['http_method']
			@params          = @attrs['params'].nil? ? {} : @attrs['params']
			@extract_dynvars = @attrs['extract_dynvars'].nil? ? {} :  @attrs['extract_dynvars']
			@url_dynvar 		 = false
			@has_dynvars     = params_contain_dynvars? || url_contains_dynvars?
			@matches         = load_matches
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

		# we add the default matches from the config into this snippet, if there are no matches specified in the snippet itself.
		def add_default_matches(config)
			@matches = config.default_matches if @matches.empty?
		end



		private

		def load_matches
			matches = []
			if @attrs['matches']
				@attrs['matches'].each { |match_name| matches << Match.new(match_name) }
			end
			matches
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