
require_relative 'tsung_wrapper'

module TsungWrapper


  class DumpFileErrorExtractor

    def initialize(filename)
      @ifile = File.open(filename, 'r')
      @ofile = File.open(format_ofile_name(filename), 'w')
      check_header_line
      # puts "extracting error responses to #{format_ofile_name(filename)}"
    end


    def run
      i = 0
      while !@ifile.eof do
        line = @ifile.readline.chomp
        fields = line.split(';')
        if fields[6] != '200' && fields[6] != '302'
          @ofile.puts line
          i += 1
        end
      end
      puts "#{i} records written."
    end


    private

    def format_ofile_name(filename)
      filename =~ /(.*?)(\.csv)?$/
      return "#{$1}_errors.csv"
    end

     def check_header_line
      line = @ifile.readline.chomp
      if line != "#date;pid;id;http method;host;URL;HTTP status;size;duration;transaction;match;error;tag"
        puts "++++++ DEBUG ++++++ #{__FILE__}::#{__LINE__} ++++\n"
        puts line
        raise "Error: Unexpected first line - was it created with the dumptraffic=\"protocol\" option?:\n#{line}"
      end
      @ofile.puts line
    end


  end
end