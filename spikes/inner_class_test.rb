class OuterClass


  class InnerClass
    def initialize()
      puts "Initialising Inner class"
    end

    def run
      puts "running inner class"
    end
  end
    


  def initialize()
    puts "intialising outer class"
  end
  

  def run
    puts 'running outer class'
    ic = InnerClass.new
    ic.run
    puts "finishing outer class"
  end
end


