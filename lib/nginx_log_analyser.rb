require 'json'
require 'csv'
require_relative 'tsung_wrapper'

class NginxLogAnalyser

	def initialize
		@log = File.new(File.join(TsungWrapper.root, 'log', 'nginx.log'), 'r')
		@headers = %w{ timestamp remote_addr remote_user body_bytes_sent request_time status request request_method }
		@fields = %w{ remote_addr remote_user body_bytes_sent request_time status request request_method }
	end

	def run
		CSV.open(File.join(TsungWrapper.root, 'log', 'ngninx.csv'), 'w') do |csv|
			csv << @headers
			while !@log.eof? do
				line = @log.readline
				hash = JSON.parse(line)
				array = []
				array << hash['@timestamp']
				fields = hash['@fields']
				@fields.each do |field|
					array << fields[field]
				end
				csv << array
			end
		end

	end
	

end

NginxLogAnalyser.new.run

