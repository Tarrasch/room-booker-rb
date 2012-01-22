shotgun: shotgun -p 4000 config.ru
beanstalkd: beanstalkd
stalk: bundle exec stalk config/jobs.rb
faye: rackup config/faye.ru -s thin -E production -p 9999