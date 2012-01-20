require "rest-client"
require "nokogiri"
require "yaml"
require "uri"
require "cgi"
require "acts_as_chain"
class RoomBooker
  acts_as_chain :username, :password, :from, :to
    
  def perform
    
  end
  
  def rooms
    return @rooms if @rooms
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
    }.join % [@from.strftime("%Y%m%d"), @from.hour, @to.hour]

    doc = Nokogiri::HTML(RestClient.get(rooms, cookies: authenticate))
    # A list of rooms ["5013", "..."]
    @rooms = doc.css(".infoboxtitle").map{|r| r.text}
  end
  
private
  def authenticate
    return @cookies if @cookies
    data = {
      authServer: "student",
      username: @username,
      password: @password,
      fragment: nil,
      x: 0,
      y: 0
    }
    
    RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data) { |response, request, result, &block| 
      return @cookies = response.cookies
    }
  end
end