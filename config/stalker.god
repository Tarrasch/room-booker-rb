rails_root = File.expand_path("../..", __FILE__)
exec       = "/usr/local/rvm/bin/webmaster_bundle exec"

God.watch do |w|
  w.name  = "scraper"
  w.group = "timeedit"
  w.interval = 30.seconds
  w.dir      = File.dirname(__FILE__)

  w.env = {
    "BUNDLE_GEMFILE" => "#{rails_root}/Gemfile",
    "RAILS_ENV" => "production",
    "BEANSTALK_URL" => "beanstalk://127.0.0.1:54132"
  }
  
  w.start = "#{exec} stalk #{rails_root}/config/jobs.rb"

  # Delay for X seconds on start/stop
  w.start_grace = 5.seconds
  w.stop_grace  = 5.seconds

  # w.uid = "webmaster"
  # w.gid = "webmaster"

  w.log = "/tmp/timeedit.stalker.log"

  # Monitoring:
  w.start_if do |start|
    start.condition(:process_running) { |c| c.running = false }
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 200.megabytes
      c.times = [3, 5]
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 95.percent
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
