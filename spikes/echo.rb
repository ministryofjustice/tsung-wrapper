

puts "xxxx"

pipe = IO.popen('echo hello')
output = pipe.readlines
pipe.close
puts output


puts 'ddd'