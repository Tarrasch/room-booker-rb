# -*- encoding : utf-8 -*-

require "rest-client"
require "nokogiri"
require "cgi"
require "acts_as_chain"

class RoomBooker
  def to_s
    (self.instance_variables - [:@password]).map { |member|
      "#{member}: #{instance_variable_get member}"
    }.join "\n"
  end

  acts_as_chain :date
  
  #
  # @args Hash {
  #   username: "username",
  #   password: "password",
  #   from: "12",
  #   to: "15",
  #   date: 5.days.from_now
  # }
  #
  def initialize(args)
    args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    raise "#from can't be smaller than #to"  if hour_from.to_i - hour_to.to_i > 0
    @_raw_rooms, @_rooms = {}, {}
  end
  
  # Like book! but doesn't throw
  #
  # @room String The room that should be booked
  # @return Bool Did everything went okay? Will also return false on RestClient::Exception
  #
  def book_safe!(room)
    book! room
  rescue RestClient::Exception
    false
  end
  #
  # @room String The room that should be booked
  # @return Bool Did everything went okay?
  #
  def book!(room)
    found_id = raw_rooms.select{ |r| r[:number] == room }.first
    raise "invalid room" unless found_id
    id = found_id[:id]
        
    url = %w{
      https://web.timeedit.se/chalmers_se/db1/b1/r.html?
      sid=1002&
      id=-1&
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
      nocache=3
    }.join % [
      date,
      hour_from, 
      hour_to, 
      "203460.192,Övrigt", 
      "#{id},#{room}"
    ].map { |x| CGI.escape(x) }
    
    post_data = {
      dates: date,
      endTime: hour_to,
      fe2: nil,
      fe8: nil,
      id: -1,
      kind: "reserve",
      startTime: hour_from,
      url: url,
    }.each_pair.map{|index, value| "#{index}=#{CGI.escape(value.to_s)}"}.join("&") + "&o=203460.192&o=#{id}"

    !! RestClient.post(url, post_data, cookies: authenticate, timeout: 5)
  end
  
  #
  # @return Array<String> A list of rooms ["1234"]
  #
  def rooms
    @_rooms[date] ||= raw_rooms.map{ |room| room[:number] }
  end
  
  #
  # @return Bool Is the given username and password valid?
  #
  def valid_credentials?
    authenticate.any?
  end
  
  #
  # @date String | Time
  #
  def date=(date)
    @date = date
  end
private

  def raw_rooms
    @_raw_rooms[date] ||= fetch_rooms!
  end
  
  def fetch_rooms!
    url = %w{
      https://web.timeedit.se/chalmers_se/db1/b1/objects.html?
      max=15&
      fr=t&
      partajax=t&
      im=f&
      add=f&
      sid=1002&
      step=1&
      grp=5&
      types=186&
      dates=%s&
      starttime=%s&
      endtime=%s
    }.join % [date, hour_from, hour_to].map { |x| CGI.escape(x) }
    
    doc = Nokogiri::HTML(RestClient.get(url, cookies: authenticate, timeout: 5))
    raw = doc.css(".infoboxtitle").map do |r| 
      # Room number "5210"
      number = r.text
      # Room object id 1224631.186
      id = doc.at_css("[data-name='#{number}']").attr("data-id")
      {id: id, number: number}
    end 
    
    
    return raw
  end
  
  def date
    if defined?(@date) and @date.is_a?(Time)
      @date.strftime("%Y%m%d")
    else
      @from.strftime("%Y%m%d")
    end
  end
  
  def hour_from
    if @from.is_a?(Time) 
      "#{@from.hour}:#{@from.min}"
    else
      @from =~ /:/ ? @from : "#{@from}:00"
    end
  end
  
  def hour_to
    if @to.is_a?(Time) 
      "#{@to.hour}:#{@to.min}"
    else
      @to =~ /:/ ? @to : "#{@to}:00"
    end
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
    
    RestClient.post("https://web.timeedit.se/chalmers_se/db1/b1/", data, timeout: 5) { |response, request, result, &block| 
      return @cookies = response.cookies
    }
  end
end
