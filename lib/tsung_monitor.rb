

command = "tsung status"


while true do
  puts ">>>>> TSUNG STATUS AT #{Time.now.strftime('%H:%M:%S')} <<<<<<<<<"
  pipe = IO.popen(command)
  lines = pipe.readlines
  puts lines
  sleep 60
end