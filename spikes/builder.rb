require 'builder'

@xml = ""
@builder = Builder::XmlMarkup.new(:target => @xml, :indent => 2)
@builder.options do
	@builder.option(:type => 'ts_http', :name => 'user_agent') do |ua|
		ua.user_agent('content', :attr => 'abd') 
	end
end

puts @xml




 # builder.person { |b| b.name("Jim"); b.phone("555-1234") }
  #
  # Prints:
  # <person>
  #   <name>Jim</name>
  #   <phone>555-1234</phone>
  # </person>