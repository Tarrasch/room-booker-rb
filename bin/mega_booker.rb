require_relative '../lib/room_booker.rb'
require 'active_support/all'

from_time = "00:00"
to_time   = "23:59"
user_hash = YAML.load_file 'user.yml'
user_hash[:from] = from_time
user_hash[:to]   = to_time

rb = RoomBooker.new user_hash

puts "Starting to book from how many days ? "
start_day = gets.chomp.to_i
puts "Ending to book from how many days (inclusive) ? "
end_day   = gets.chomp.to_i

dates = (start_day..end_day).map { |x| x.days.from_now}

roomss = []
dates.each { |d|
  rb.date = d
  roomss << rb.rooms
}

int = roomss.inject(:&)
puts "The following intersection was found: "
p int

puts "Sorry, nothing to book" && exit if int.empty?

puts "Enter [#room|exit|all!]"
input = ""
input = gets.chomp until (int + ['exit', 'all!']).member?(input)

exit if input == 'exit'
rooms   = int if input == 'all!'
rooms ||= [input]

print "You want rooms #{rooms}, starting to book!\n\n"

dates.each { |date|
  rb.date = date
  rooms.each { |room|
    res = rb.book_safe!(room) ? 'BOOKED' : 'FAILED'
    print "#{res} room #{room}, #{from_time}-#{to_time} on #{date.to_date}\n"
  }
}

print "\nDONE! Exited succesfully\n"
