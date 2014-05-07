module TsungWrapper

  class DumpFileUrlAnalyser

    def initialize(filename)
      @ifile      = File.open(filename, 'r')
      @ofile      = File.open(format_ofile_name(filename), 'w')
      @urls       = Hash.new
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
      url = OpenStruct.new
      url.esecs = calculate_elapsed_time(fields.first)
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




  end
end