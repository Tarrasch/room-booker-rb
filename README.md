# Room Booker

Chalmers room booking application.
An alternative to [Timeedit](http://web.timeedit.se/chalmers_se), which sucks. 

A live demo can be found @ [timeedit.oleander.nu](http://timeedit.oleander.nu).  
Your browser must support HTML5's [local storage](http://dev.w3.org/html5/webstorage/), you can test your browser [here](http://html5test.com/).

## Web application

### Setup

1. Install [beanstalkd](http://kr.github.com/beanstalkd/). `brew install beanstalkd` can be used in OS X
2. Clone project `git clone git://github.com/Tarrasch/room-booker-rb.git`
3. Navigate to `room-booker` and install dependencies using `bundle install`
4. Install [foreman](http://railscasts.com/episodes/281-foreman) globaly using `[sudo] gem install foreman`
5. Start [Faye](http://faye.jcoglan.com/), beanstalkd, [Sinatra](http://www.sinatrarb.com/) and [Stalker](https://github.com/han/stalker) using `foreman start`
6. Navigate to [localhost:4000](http://localhost:4000) and you're done!

## RoomBooker class

Core class, may be used without the web interface.

### Initialize

``` ruby
room_booker = RoomBooker.new({
  username: "username",
  password: "password",
  from: "12",
  to: "14",
  date: Time.now
})
``` 

### Get a list of available rooms

``` ruby
room_booker.rooms # => ["1234", "5678"]
```

### Book a room

``` ruby
room_booker.book!("1234") # => true
```

### Constructor params

- **username** (String) Chalmers id, CID
- **password** (String) CID password.
- **from** (Fixnum) When does it start? (24 hour clock).
- **to** (Fixnum) When does it end? (24 hour clock).
- **date** (Time) What day?

### Other methods

- **valid_credentials?** (Bool) Is the given username and password valid?

## Testing

1. Export `USERR` and `PASSWORD` vars using `export USERR="username"`, `export PASSWORD="password"`.
2. Run specs using `rspec .`

## License

*Room Booker* is released under the *MIT license*.