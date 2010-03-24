describe Orange::Middleware::Base do
  it "should call init after initializing" do
    lambda{
      mid = MockOrangeDeathMiddleware.new(nil, Orange::Core.new, :foo => 'bar')
    }.should raise_error(RuntimeError, "middleware_init with foo=bar")
  end
  
  it "should create a packet and call packet call" do
    mid = MockOrangeBasedMiddlewareTwo.new(nil, Orange::Core.new)
    mid.should_receive(:packet_call).with(an_instance_of(Orange::Packet))
    mid.call({})
  end
  
  it "should pass the packet on by default for packet_call" do
    mid = MockOrangeBasedMiddlewareTwo.new(nil, Orange::Core.new)
    mid.should_receive(:pass).with(an_instance_of(Orange::Packet))
    mid.packet_call(empty_packet)
  end
  
  it "should call the downstream app on pass" do
    app = mock("downstream")
    app2 = mock("downstream_orange")
    my_hash = {:foo => :bar}
    app.should_receive(:call).with(my_hash).and_return([{},200,[]])
    app2.should_receive(:packet_call).with(an_instance_of(Orange::Packet))
    mid = MockOrangeBasedMiddlewareTwo.new(app, Orange::Core.new)
    mid2 = MockOrangeBasedMiddlewareTwo.new(app2, Orange::Core.new)
    mid.call(my_hash)
    mid2.call(my_hash)
  end
  
  it "should give access to the orange core on calling orange" do
    c = Orange::Core.new
    mid = MockOrangeBasedMiddlewareTwo.new(nil, c)
    mid.orange.should equal c
  end

end