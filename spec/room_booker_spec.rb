describe RoomBooker do
  subject { 
    RoomBooker.new({
      username: $username,
      password: $password,
      from: 1.day.from_now,
      to: 1.day.from_now + 3.hours
    })
  }
  
  describe "#rooms" do    
    use_vcr_cassette "rooms"
    it { should have(15).rooms }
    it { subject.rooms.each{|room| room.should be_instance_of(String)} }
  end
  
  describe "#book!" do
    let(:room) { subject.rooms.first }
    use_vcr_cassette "book"
    it { subject.book!(room).should be_true }
  end
end