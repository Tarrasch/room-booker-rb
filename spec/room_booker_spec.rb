describe RoomBooker do
  subject { RoomBooker.new.username(`echo $USERR`.strip).password(`echo $PASSWORD`.strip).from(1.day.from_now).to(1.day.from_now + 3.hours) }
  it "should return a list of rooms" do
    should have(15).rooms
  end
end