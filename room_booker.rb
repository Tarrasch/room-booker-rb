require "rest-client"
require "nokogiri"
require "yaml"
require "uri"
require "cgi"

data = {
  authServer: "student",
  username: "oleander",
  password: ARGV.first,
  fragment: nil,
  x: 0,
  y: 0
}

from    = 12 # 12:00
to      = 15 # 15:00
date    = "20120121"
cookies = {}

data = RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data) { |response, request, result, &block| 
  cookies = response.cookies
}

rooms = %w{
  https://web.timeedit.se/chalmers_se/db1/timeedit/p/b1/objects.html?
  max=15&
  fr=t&
  partajax=t&
  im=f&
  add=f&
  sid=1002&
  step=1&
  grp=5&
  objects=160177.184,203433.185&
  types=186&
  dates=%s&
  starttime=%s:0&
  endtime=%s:0
}.join % [date, from, to]

# A list of rooms
doc     = Nokogiri::HTML(RestClient.get(rooms, cookies: cookies))
rooms   = doc.css(".infoboxtitle").map{|r| r.text} # A list of rooms ["5013", "..."]
room    = rooms.sample # Selecting random room "5013"
room_id = doc.at_css("[data-name='#{room}']").attr("data-id")

url = %w{
  https://web.timeedit.se/chalmers_se/db1/timeedit/p/b1/r.html?
  sid=1002&
  h=t&
  id=-1&
  step=2&
  cn=0&
  id=-1&
  dates=%s&
  startTime=%s&
  endTime=%s&
  o=%s&
  o=%s&
  o=%s&
  nocache=3
}.join % [date, "#{from}:0", "#{to}:0", "160177.184,pr101", "203433.185,ks91084", "#{room_id},#{room}"].map { |x| GGI.escape(x) }

post_data = {
  dates: date,
  endTime: "#{to}:00",
  fe2: nil,
  fe8: nil,
  id: -1,
  kind: "reserve",
  startTime: "#{from}:00",
  url: url
}.each_pair.map{|index, value| "#{index}=#{CGI.escape(value.to_s)}"}.join("&") + "&o=160177.184&o=203433.185&o=#{room_id}"

puts RestClient.post(url, post_data, cookies: cookies)
