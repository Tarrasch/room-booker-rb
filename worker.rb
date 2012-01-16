require "rest-client"
require "nokogiri"
require "yaml"

username = `echo $USERNAME2`.strip
password = `echo $PASSWORD`.strip

data = {
  authServer: "student",
  username: username,
  password: password,
  fragment: nil,
  x: 0,
  y: 0
}

p username

data = RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data)
puts data.cookies.to_yaml
puts !! data.match(/Arash Rouhani/)
