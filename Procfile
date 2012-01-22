export: export FAYE_TOKEN=31033a4327cb9e0dcb2570bcfd0ffe24
shotgun: shotgun -p 4000 config.ru
faye: FAYE_TOKEN=31033a4327cb9e0dcb2570bcfd0ffe24 rackup config/faye.ru -s thin -E production -p 9999
beanstalkd: beanstalkd
stalk: bundle exec stalk config/jobs.rb