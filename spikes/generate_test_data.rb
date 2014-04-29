

filename = File.join(File.dirname(__FILE__), '/../config/data/google_usernmes.csv')

File.open(filename, 'w') do |fp|

  (1..30000).each do |i|
    fp.puts %Q{"gdfsdfe234+#{i}@gmail.com"}
  end
end