require "stalker"
require "yaml"
include Stalker

job "timeedit" do |args|
  puts args.to_yaml
end