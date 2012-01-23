require "rspec"
require "webmock/rspec"
require "vcr"
require "timecop"
require "activesupport"
require_relative "../lib/room_booker"

$username = `echo $USERR`.strip
$password = `echo $PASSWORD`.strip

Timecop.freeze(Time.parse("2012-01-25"))
  
RSpec.configure do |config|
  config.mock_with :rspec
  config.extend VCR::RSpec::Macros
end

VCR.config do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.stub_with :webmock
  c.default_cassette_options = {
    record: :new_episodes
  }
  c.allow_http_connections_when_no_cassette = false
  c.filter_sensitive_data('<username>') { $username }
  c.filter_sensitive_data('<password>') { $password }
end