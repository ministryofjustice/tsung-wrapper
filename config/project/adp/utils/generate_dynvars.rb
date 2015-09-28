class GenerateDynvars

  def initialize(num_records_to_create = 50_000)
    @prefixes              = %w{ A B C D E F G H J K L M N P Q R S T U V W X Y Z }
    @numeric_range         = (12345678..87654321)
    @filename              = File.dirname(__FILE__) + '/../data/case_numbers.csv'
    @num_records_to_create = num_records_to_create
  end

  def run
    fp = File.new(@filename, 'w')
    count = 0
    @numeric_range.each do |i|
      break unless count < @num_records_to_create
      @prefixes.each do |x|
        break unless count < @num_records_to_create
        fp.puts %Q["#{x}#{i}"]
        count +=1

      end
    end


  end



end


GenerateDynvars.new.run