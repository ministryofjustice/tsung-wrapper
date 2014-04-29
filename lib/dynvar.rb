require 'builder'
require 'digest/md5'

require_relative 'tsung_wrapper'


module TsungWrapper

	class Dynvar
		include Comparable

		attr_reader :varname, :type, :length, :start, :end, :code, :filename, :fileid, :order, :delimiter

		def initialize(dynvar_definition_name, varname)
			# @attrs  = []
		  @type         = nil
		  @length       = nil
		  @start        = nil
		  @end          = nil
		  @code         = nil
		  @varname      = varname
		  @varnames 		= nil

			filename = File.join(TsungWrapper.config_dir, 'dynvars', "#{dynvar_definition_name}.yml")
		  unless File.exist?(filename)
		  	raise ArgumentError.new("No Dynamic Variable snippet with name '#{dynvar_definition_name}' can be found.")
		  end

		  @config = YAML.load_file(filename)['dynvar']
		  valid_types = %w{ random_string random_number erlang file }
		  unless valid_types.include?(@config['type'])
		  	raise ArgumentError.new("Invalid type '#{@config['type']}' defined in Dynamic Variable snippet.")
		  end

		  case @config['type']
		  when 'random_string'
		  	populate_random_string
		  when 'random_number'
		  	populate_random_number
		  when 'erlang'
		  	populate_erlang
		  when 'file'
		  	populate_file
		  end
		end

		# produces a hash which can be passed as the attributes to the <setdynvars> element
		def attr_hash
			hash = {:sourcetype => @type}
			case @type
			when 'random_string'
				hash[:length] = @length
			when 'random_number'
				hash[:start] = @start
				hash[:end] = @end
			when 'eval'
				hash[:code] = @code.chomp.to_sym			# symbolize it in order to prevent it from being escaped
			when 'file'
				hash[:fileid] = @fileid
				hash[:delimiter] = @delimiter
				hash[:order] = @order
			end
			hash
		end


		def to_xml(builder)
			builder.setdynvars(self.attr_hash) do
				builder.var(:name => @varname)
			end
		end


		def is_file_dynvar?
			@type == 'file'
		end



		# These two methods are here so that file_dynvars can be uniqued by fileid
		def eql?(other)
			self.fileid.eql?(other.fileid)
		end


		def hash
			is_file_dynvar? ? TsungWrapper.md5_to_i(@fileid) : super
		end

		# returns the full filepath of the csv file
		def filepath
			File.join(TsungWrapper.config_dir, 'data', @filename)
		end



		private

		def populate_file
			validate_file_dynvar
			@attrs     = [ :fileid,  :order, :delimiter]
			@type      = 'file'
			@filename  = @config['filename']
			@fileid    = Digest::MD5.hexdigest(@filename)
			@order     = translate_file_access
			@delimiter = @config['delimiter']
		end


		def validate_file_dynvar
			# check that the CSV file really exists
			csv_filename = File.join(TsungWrapper.config_dir, 'data', @config['filename'])
			unless File.exist?(csv_filename)
				raise ArgumentError.new("CSV file '#{csv_filename}' cannot be found.")
			end
		end



		def translate_file_access
			case @config['access']
			when 'sequential'
				'iter'
			when 'random'
				'random'
			else
				raise ArgumentError.new('Invalid access specified for file_dynvar')
			end
		end



		def populate_random_string
			@attrs    = [:sourcetype, :length]
			@type     = 'random_string'
			@length   = @config['length']
			@varnames = [@varname]
		end


		def populate_random_number
			@attrs    = [:sourcetype, :start, :end]
			@type     = 'random_number'
			@start    = @config['start']
			@end      = @config['end']
			@varnames = [@varname]
		end


		def populate_erlang
			@attrs    = [:sourcetype, :code]
			@type     = 'eval'
			@code     = @config['code']
			@varnames = [@varname]
		end
	end

end
