require "sinatra"
require "haml"
require "yaml"
require "uuid"
require "stalker"

if ENV["RACK_ENV"] == "production"
  Stalker.connect("beanstalk://127.0.0.1:54132")
end

before do  
  uuid = request.cookies["uuid"]
  if not uuid or uuid.empty?
    response.set_cookie("uuid", UUID.new.generate)
  end
end

get "/" do
  haml :index
end

post "/reservation" do
  Stalker.enqueue("timeedit", params.merge({
    uuid: request.cookies["uuid"]
  }))
  
  halt 204, "ok"
end