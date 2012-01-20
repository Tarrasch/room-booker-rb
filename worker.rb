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

cookies = {}
data = RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data) 
  { |response, request, result, &block| cookies = response.cookies}

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
  dates=20120119&
  starttime=23:0&
  endtime=24:0
}.join

# A list of rooms
doc     = Nokogiri::HTML(RestClient.get(rooms, cookies: cookies))
rooms   = doc.css(".infoboxtitle").map{|r| r.text} # A list of rooms ["5013", "..."]
room    = rooms.sample # Selecting random room "5013"
room_id = doc.at_css("[data-name='#{room}']").attr("data-id")
from    = 12 # 12:00
to      = 15 # 15:00
date    = "20120121"

url = %w{
  https://web.timeedit.se/chalmers_se/db1/timeedit/p/b1/r.html?
  sid=1002&
  h=t&
  id=-1&
  step=2&
  cn=0&
  id=-1&
  dates=%s&
  startTime=%s:0&
  endTime=%s:0&
  o=%s&
  o=%s&
  o=%s,%s&
  nocache=3
}.join % [date, from, to, CGI.escape("160177.184,pr101"), CGI.escape("203433.185,ks91084"), room_id, room]

post_data = {
  dates: date,
  endTime: "#{to}:00",
  fe2: nil,
  fe8: nil,
  id: -1,
  kind: "reserve",
  startTime: "#{from}:00",
  uri: url
}.each_pair.map{|index, value| "#{index}=#{CGI.escape(value.to_s)}"}.join("&") + "&o=160177.184&o=203433.185&o=#{room_id}"

# TODO: Make it work
# puts RestClient.post(url, post_data, cookies: cookies)