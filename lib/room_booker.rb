require "rest-client"
require "nokogiri"
require "cgi"
require "acts_as_chain"

class RoomBooker
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
    raise "#from can't be smaller than #to" if hour_from - hour_to > 0
  end
  
  #
  # @room String The room that should be booked
  # @return Bool Did everything went okay?
  #
  def book!(room)
    found_id = @rooms.select{ |r| r[:number] == room }.first
    raise "invalid room" unless found_id
    id = found_id[:id]
    
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
      date,
      "#{hour_from}:0", 
      "#{hour_to}:0", 
      "160177.184,pr101", 
      "203433.185,ks91084", 
      "#{id},#{room}"
    ].map { |x| CGI.escape(x) }
    
    post_data = {
      dates: date,
      endTime: "#{hour_to}:00",
      fe2: nil,
      fe8: nil,
      id: -1,
      kind: "reserve",
      startTime: "#{hour_from}:00",
      url: url,
    }.each_pair.map{|index, value| "#{index}=#{CGI.escape(value.to_s)}"}.join("&") + "&o=160177.184&o=203433.185&o=#{id}"

    !! RestClient.post(url, post_data, cookies: authenticate)
  end
  
  #
  # @return Array<String> A list of rooms ["1234"]
  #
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
    }.join % [date, hour_from, hour_to]

    doc = Nokogiri::HTML(RestClient.get(rooms, cookies: authenticate))
    @rooms = doc.css(".infoboxtitle").map do |r| 
      # Room number "5210"
      number = r.text
      # Room object id 1224631.186
      id = doc.at_css("[data-name='#{number}']").attr("data-id")
      {id: id, number: number}
    end
    
    return room_numbers
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
  def room_numbers
    @rooms.map{|room| room[:number]}
  end
  
  def date
    if defined?(@date) and @date.is_a?(Time)
      @date.strftime("%Y%m%d")
    else
      @from
    end
  end
  
  def hour_from
    @from.is_a?(Time) ? @from.hour : @from.to_i
  end
  
  def hour_to
    @to.is_a?(Time) ? @to.hour : @to.to_i
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