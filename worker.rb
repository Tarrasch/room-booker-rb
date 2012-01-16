require "rest-client"
require "nokogiri"
require "yaml"

data = {    
  authServer: "student",
  username: "oleander",
  password: "abc123",
  fragment: nil,
  x: 0,
  y: 0
}
  
data = RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data)
puts data.cookies.to_yaml