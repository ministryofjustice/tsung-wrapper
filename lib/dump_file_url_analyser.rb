module TsungWrapper

  class DumpFileUrlAnalyser

    def initialize(filename)
      @ifile      = File.open(filename, 'r')
      @ofile      = File.open(format_ofile_name(filename), 'w')
      @urls       = Hash.new(Array.new)
      @start_time = nil

      check_header_line
      puts "Analysing URL repsonsees to  #{format_ofile_name(filename)}"
    end

    def run
      while !@ifile.eof do
        line = @ifile.readline.chomp
        process_line
      end
      generate_totals
    end





    private


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
      normalised_url = normalise_url(fields[5])
      url = OpenStruct.new
      url.esecs = calculate_elapsed_time(fields.first)
      url.duration = fields[8].to_f
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
      elsif url =~ /(.*)\/\?.+/
        normalised_url = $1
      elsif url =~ /(.*)\/?$/
        normalised_url = $1
      end
      normalised_url.nil? ? '' : normalised_url
    end



  end
end