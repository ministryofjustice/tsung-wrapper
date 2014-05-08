require 'ostruct'

@urls = []

url                 = OpenStruct.new
url.esecs           = 1.4
url.duration        = 0.33
url.response_status = '202'
@urls << url


url                 = OpenStruct.new
url.esecs           = 1.4
url.duration        = 0.73
url.response_status = '202'
@urls << url



url                 = OpenStruct.new
url.name            = 'activate'
url.esecs           = 1.4
url.duration        = 0.46
url.response_status = '202'
@urls << url


puts "count: #{@urls.size}"
puts "sum: #{@urls.inject(0){ |sum, x| sum + x.duration } }"
puts "max: #{@urls.max_by{ |os| os.duration}.duration }"

