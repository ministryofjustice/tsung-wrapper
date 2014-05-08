require 'csv'

module TsungWrapper

  class DumpFileUrlAnalyser

    def initialize(filename)
      @filename   = filename
      @ifile      = File.open(@filename, 'r')
      @urls       = Hash.new(Array.new)
      @start_time = nil

      check_header_line
    end

    def run
      while !@ifile.eof do
        line = @ifile.readline.chomp
        process_line(line)
      end
      @response_codes = response_codes
      generate_totals
    end





    private

    def generate_totals
      header = %w{ url num_requests avg min max max_elapsed }
      header += @response_codes
      CSV.open(format_ofile_name(@filename), "wb") do |csv|
        csv << header
        @urls.each { |url, ostruct_array| csv << format_output_for_url(url, ostruct_array) }
      end
    end


    # iterate through the array of structs for this url, summarising the totals for ervery url and outputting to CSV
    def format_output_for_url(url, ostruct_array)
      # url num_requests avg min max max_elapsed 
      response_codes = Hash.new(0)
      count = 0
      total_duration = 0
      min_duration = 9999999999
      max_duration = 0
      max_elapsed = 0
      ostruct_array.each do |ostruct|
        count           == 1
        total_duration += ostruct.duration
        min_duration    = ostruct.duration if ostruct.duration < min_duration
        max_duration    = ostruct.duration if ostruct.duration > max_duration
        max_elapsed     = ostruct.duration if ostruct.duration > max_duration
      end
      arr = [url, count, (total_duration.to_f / count).round(2), min_duration, max_duration, max_elapsed]
    end




    def response_codes
      codes = []
      @urls.each do |arr|
        codes << arr.map(&:response_status)
      end
      codes.flatten.uniq.sort
    end


    def is_first_line?
      @start_time.nil?
    end

    # line fields are:
    # 0   - date
    # 1   - pid
    # 2   - id
    # 3   - http method
    # 4   - host
    # 5   - URL
    # 6   - HTTP status
    # 7   - size
    # 8   - duration
    # 9   - transaction
    # 10  - match
    # 11  - error
    # 12  - tag
    def process_line(line)
      fields = line.split(';')
      if is_first_line?
        @start_time = fields.first.to_f
      end
      normalised_url      = normalise_url(fields[5])
      url                 = OpenStruct.new
      url.esecs           = calculate_elapsed_time(fields.first)
      url.duration        = fields[8].to_f
      url.response_status = fields[6].to_s
      @urls[normalised_url] << url
    end

    def calculate_elapsed_time(field)
      (field.to_f - @start_time).to_i
    end


    def format_ofile_name(filename)
      filename =~ /(.*?)(\.csv)?$/
      return "#{$1}_urls.csv"
    end

    def check_header_line
      line = @ifile.readline.chomp
      if line != "#date;pid;id;http method;host;URL;HTTP status;size;duration;transaction;match;error;tag"
        raise "Error: Unexpected first line - was it created with the dumptraffic=\"protocol\" option?:\n#{line}"
      end
    end


    def normalise_url(url)
      if url =~ /\/activate\/.+/
        normalised_url = '/activate'
      elsif url =~ /(.*)\/?\?.*/
        normalised_url = $1
      else
        normalised_url = url
      end
      normalised_url = normalised_url.nil? ? '' : normalised_url
      normalised_url.sub(/\/$/,'')             # remove trailing slash if present
    end


  end
end