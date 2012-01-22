require "stalker"
require "secure_faye"
require "yaml"
require "jsonify"
require_relative "lib/room_booker"

include Stalker

job "timeedit" do |args|
  sf = SecureFaye::Connect.new.
    token("31033a4327cb9e0dcb2570bcfd0ffe24").
    server("http://localhost:9999/faye").
    channel("/reserve/" + args["uuid"])
  
  rb = RoomBooker.new({
    from: args["from"],
    to: args["to"],
    password: `echo $PASSWORD`.strip,
    username: `echo $USERR`.strip
  })
  
  unless rb.valid_credentials?
    sf.message({
      type: "message",
      message: "Invalid credentials"
    }).send!; next
  end
  
  args["days"].each do |day|
    rb.date = Time.at(day.to_i)
    if room = rb.rooms.select{ |room| room.split("").first == args["floor"].to_s }.first
      begin
        rb.book!(room)
      rescue
        message = $!.message || "Something went wrong"
      ensure
        message ||= "valid"
      end
    else
      message = "no_room"
    end
    
    hash = {
      type: "message",
      notification: message,
      room: room,
      day: day
    }
    
    sf.message(hash.to_json).send!
  end
  
  sf.message({
    type: "end"
  }.to_json).send!
end