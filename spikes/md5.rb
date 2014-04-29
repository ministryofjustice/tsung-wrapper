require 'digest/md5'


# 13054729925367


def md5_to_i(str)
  i = 0
  j = 1
  str.each_byte do |n|
    i += (n * j)
    j *= 10
  end
  i
end

[ 'username', 'username.csv', 'username_a.csv', 'username_b.csv'].each do |str|
  
  digest = Digest::MD5.hexdigest(str)
  puts md5_to_i(digest)
end

