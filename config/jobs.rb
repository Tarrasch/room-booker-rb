require "stalker"
require "secure_faye"
require "yaml"
require "time"
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

job "reserve.now" do |args|
  sf = SecureFaye::Connect.new.
    token("65E16044301D624A9F8741430755B5112AE4562F").
    server("http://0.0.0.0:9999/faye").
    channel("/reserve/" + args["uuid"])
    
  begin
    time = Time.now
    end_of_day = Time.parse("#{time.year}-#{"%02d" % time.month}-#{"%02d" % time.day} 23:59")
    rb = RoomBooker.new({
      from: time,
      to: end_of_day,
      password: args["password"],
      username: args["username"]
    })
  rescue RuntimeError
    sf.message({
      notification: $!.message,
      type: "message"
    }.to_json).send!; next
  end
  
  room = rb.rooms.reject{ |room| room.to_i.zero? }.sample
  
  if room 
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
    day: time.to_i
  }
  
  sf.message(hash.to_json).send!
end

job "reserve.by" do |args|
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
    
    if args["floor"] == "0"
      room = rb.rooms.reject{ |room| room.to_i.zero? }.sample
    else
      room = rb.rooms.select{ |room| room.split("").first == args["floor"] }.first
    end
    
    if room 
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