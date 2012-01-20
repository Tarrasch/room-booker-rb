describe RoomBooker do
  describe "time objects" do
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
  
  describe "time strings" do
    subject { 
      RoomBooker.new({
        username: $username,
        password: $password,
        from: "12",
        to: "14",
        date: Time.now
      })
    }

    describe "#rooms" do    
      use_vcr_cassette "rooms"
      it { should have(15).rooms }
      it { subject.rooms.each{|room| room.should be_instance_of(String)} }
    end
  end
  
  describe "other" do
    it "does not except negative times" do
      lambda {
        RoomBooker.new({
          from: "19",
          to: "15"
        })
      }.should raise_error(RuntimeError, "#from can't be smaller than #to")
    end
    
    it "should not be valid" do
      VCR.use_cassette("invalid") do
        RoomBooker.new({
          from: "14",
          to: "15",
          password: "invalid",
          username: "invalid"
        }).valid_credentials?.should be_false
      end
    end
    
    it "should be valid" do
      VCR.use_cassette("valid") do
        RoomBooker.new({
          from: "14",
          to: "15",
          password: $password,
          username: $username
        }).valid_credentials?.should be_true
      end
    end
    
    it "should be valid" do
      VCR.use_cassette("invalid2") do
        rb = RoomBooker.new({
          from: "14",
          to: "15",
          date: Time.now,
          password: $password,
          username: $username
        })
        
        rb.rooms
        lambda { rb.book!("non-existing-room") }.should raise_error(RuntimeError, "invalid room")
      end
    end
  end
end