require "rest-client"
require "nokogiri"
require "yaml"
require "uri"
require "cgi"
require "acts_as_chain"
class RoomBooker
  acts_as_chain :username, :password, :from, :to
    
  def book
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
    }.join % [
      @from.strftime("%Y%m%d"),
      "#{@from.hour}:0", 
      "#{@to.hour}:0", 
      "160177.184,pr101", 
      "203433.185,ks91084", 
      "#{room_id},#{room}"
    ].map { |x| GGI.escape(x) }

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

    !! RestClient.post(url, post_data, cookies: authenticate)
  end
  
  def rooms
    return room_numbers if @rooms
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
    @rooms = doc.css(".infoboxtitle").map do |r| 
      number = r.text
      id = doc.at_css("[data-name='#{number}']").attr("data-id")
      {id: id, number: number}
    end
    
    return room_numbers
  end
  
private
  def room_numbers
    @rooms.map{|room| room[:number]}
  end
  
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