shotgun: shotgun -p 4000 config.ru
faye: FAYE_TOKEN=65E16044301D624A9F8741430755B5112AE4562F rackup config/faye.ru -s thin -E production -p 9999
beanstalkd: beanstalkd
stalk: bundle exec stalk config/jobs.rb