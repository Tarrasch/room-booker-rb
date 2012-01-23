require "stalker"
require "secure_faye"
require "yaml"
require "jsonify"
require_relative "../lib/room_booker"
include Stalker

Stalker.censor_params(:password, :username)

error do |e, job, args|
  sf = SecureFaye::Connect.new.
    token("65E16044301D624A9F8741430755B5112AE4562F").
    server("http://0.0.0.0:9999/faye").
    channel("/reserve/" + args["uuid"])
    
  sf.message({
    notification: "Error on server side: #{e.message}",
    type: "message"
  }.to_json).send!
end

job "timeedit" do |args|
  sf = SecureFaye::Connect.new.
    token("65E16044301D624A9F8741430755B5112AE4562F").
    server("http://0.0.0.0:9999/faye").
    channel("/reserve/" + args["uuid"])
  
  begin
    rb = RoomBooker.new({
      from: args["from"],
      to: args["to"],
      password: args["password"],
      username: args["username"]
    })
  rescue RuntimeError
    sf.message({
      notification: $!.message,
      type: "message"
    }.to_json).send!; next
  end
  
  unless rb.valid_credentials?
    sf.message({
      type: "message",
      notification: "invalid_credentials"
    }.to_json).send!; next
  end
  
  args["days"].each do |day|
    rb.date = Time.at(day.to_i)
    
    if room = rb.rooms.select{ |room| room.split("").first == args["floor"].to_s }.first
      begin
        rb.book!(room)
      rescue
        message ||= $!.message || "Something went wrong"
      ensure
        message ||= "valid"
      end
    else
      message ||= "no_room"
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