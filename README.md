# Room Booker

Chalmers room booking application.
An alternative to [Timeedit](web.timeedit.se/chalmers_se), which sucks. 

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
- **from** (Fixnum) When does it end? (24 hour clock).
- **date** (Time) What day?

## Testing

1. Export `USERR` and `PASSWORD` vars using `export USERR="username"`, `export PASSWORD="password"`.
2. Run specs using `rspec .`

## License

*Room Booker* is released under the *MIT license*.