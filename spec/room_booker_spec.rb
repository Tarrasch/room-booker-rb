describe RoomBooker do
  subject { RoomBooker.new.username(`echo $USERR`.strip).password(`echo $PASSWORD`.strip).from(1.day.from_now).to(1.day.from_now + 3.hours) }
  it { should have(15).rooms }
  it { subject.rooms.each{|room| room.should be_instance_of(String)} }
end