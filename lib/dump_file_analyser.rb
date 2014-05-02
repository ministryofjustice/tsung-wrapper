require 'csv'

module TsungWrapper



  # This class will analyse a tsung.dump file which has been produced with the dumptraffic="protocol" options
  # and summarise it in intervals specified as the parameter.
  #
  # Run it from the command line with 
  #
  #      ruby lib/dfa.rb -f filename -s nn
  #
  # The output file produces has the same name as the input file with the suffix ".summary.csv"
  #
  class DumpFileAnalyser

    # Inner class to encapsulate the line read from the dump file
    #date;pid;id;http method;host;URL;HTTP status;size;duration;transaction;match;error;tag
    # 1398962662.309014;<0.94.0>;1;get;staging-lpa.service.dsd.io;/;200;13118;238.420;-;;;
    class SourceLine

      attr_reader :timestamp, :client_id, :http_verb, :server, :url, :http_status, :size, :duration

      def initialize(line)
        fields       = line.split(';')
        @timestamp   = fields[0].to_f
        @client_id   = fields[2].to_i
        @http_verb   = fields[3]
        @server      = fields[4]
        @url         = fields[5]
        @http_status = fields[6]
        @size        = fields[7].to_i
        @duration    = fields[8].to_f
      end
    end



    # # inner class to encapsualte a summary line
    class SummaryLine

      attr_reader :elapsed_time, :interval, :num_requests, :num_requests_per_second, 
                  :max_request_time, :min_request_time, :avg_request_time, :status_code_counts

      def initialize(elapsed_time, interval)
        @elapsed_time            = elapsed_time
        @interval                = interval
        @total_request_time      = 0
        @num_requests            = 0
        @num_requests_per_second = 0
        @max_request_time        = 0.0
        @min_request_time        = 99999999.99
        @avg_request_time        = nil
        @status_code_counts      = {}
      end

      def add_source_line(line)
        @num_requests += 1
        @total_request_time += line.duration
        @max_request_time = line.duration if line.duration > @max_request_time
        @min_request_time = line.duration if line.duration < @min_request_time
        add_status_code(line.http_status)
      end


      def add_status_code(http_status)
        if @status_code_counts.has_key?(http_status)
          @status_code_counts[http_status] += 1
        else
          @status_code_counts[http_status] = 1
        end
      end
      

      def http_status_codes
        @status_code_counts.keys
      end


      def finalise
        @num_requests_per_second = (@num_requests.to_f / @interval).round(4)
        @avg_request_time        = (@total_request_time / @num_requests).round(4)
        self
      end



      def to_csv(http_status_codes)
        arr = [ @elapsed_time, @num_requests, @num_requests_per_second, @min_request_time, @max_request_time, @avg_request_time ]
        http_status_codes.each do |code|
          arr << @status_code_counts[code]
        end
        arr
      end
    end


    #########################################################################################################


    # instantiate an Analyser
    #
    # @param filename [String] the name of the file to analyse
    # @param interval [Fixnum] the interval to group results

    def initialize(filename, interval)
      @filename           = filename
      @output_filename    = "#{@filename}.summary.csv"
      @interval           = interval
      @start_time         = nil
      @next_subtotal_time = nil
      @http_status_codes  = []
      @is_first_line      = true
      @summary_lines      = []

      raise ArgumentError.new("File #{filename} does not exist") unless File.exist?(filename)
      @fp = File.new(filename, 'r')
      check_header_line
    end


    def run
      summary_line = SummaryLine.new(0, @interval)
      while !@fp.eof do
        line = SourceLine.new(@fp.readline)
        if is_first_line?
          @start_time = line.timestamp
          @next_subtotal_time = @start_time + @interval
          @is_first_line = false
        end
        
        if line.timestamp < @next_subtotal_time
          summary_line.add_source_line(line)
        else
          record_summary_line(summary_line)
          summary_line = SummaryLine.new(summary_line.elapsed_time + @interval, @interval)
          summary_line.add_source_line(line)
          @next_subtotal_time += @interval
        end
      end

      record_summary_line(summary_line)
      output_results
    end


    private

    def output_results
      
      @http_status_codes.sort!
      header = %w{ elapsed_time num_reqs num_reqs_per_sec min_req_time max_req_time avg_req_time }
      header += @http_status_codes

      CSV.open(@output_filename, "wb") do |csv|
        csv << header
        @summary_lines.each { |r| 
          csv << r.to_csv(@http_status_codes) }
      end
    end




    def record_summary_line(summary_line)
      add_http_status_codes(summary_line.http_status_codes)
      @summary_lines << summary_line.finalise
    end


    def add_http_status_codes(codes)
      codes.each { |code|  @http_status_codes << code unless @http_status_codes.include?(code) }
    end



    def is_first_line?
      @is_first_line
    end



    def check_header_line
      line = @fp.readline.chomp
      if line != "#date;pid;id;http method;host;URL;HTTP status;size;duration;transaction;match;error;tag"
        raise "Error: Unexpected first line - was it created with the dumptraffic=\"protocol\" option?:\n#{line}"
      end
    end

  end
end
    




















