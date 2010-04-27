require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Packet do
  it "should return a default header content type of html" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.finish[1].should have_key("Content-Type")
    p.finish[1]["Content-Type"].should eql("text/html")
  end
  
  it "should not create a new object for env if one already exists" do
    p= Orange::Packet.new(Orange::Core.new, {})
    env = p.env
    p2= Orange::Packet.new(Orange::Core.new, env)
    p.should equal p2 # Exact equality - same instances
  end
  
  it "should save core passed to it on initialization" do
    c= Orange::Core.new
    p= Orange::Packet.new(c, {})
    p.orange.should equal c
  end
  
  it "should save the env passed to it on init" do
    p= Orange::Packet.new(Orange::Core.new, {:test => :foo})
    p.env.should have_key(:test)
    p.env[:test].should == :foo
    p.env.should_not be_empty
  end
  
  it "should add orange.packet and orange.env to env on init" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.env.should have_key('orange.packet')
    p.env['orange.packet'].should equal p
    p.env.should have_key('orange.env')
    p.env['orange.env'].should have_key(:request)
    p.env['orange.env'][:request].should be_an_instance_of(Rack::Request)
    p.env['orange.env'].should have_key(:headers)
    p.env['orange.env'][:headers].should be_an_instance_of(Hash)
  end
  
  it "should have access to the orange.env through []" do
    p= Orange::Packet.new(Orange::Core.new, {'orange.env' => {'foo' => :true}})
    p['foo'].should == :true
    p['foo'] = 'banana'
    p.env['orange.env']['foo'].should == 'banana'
    p['foo'].should == 'banana'
  end
  
  it "should allow defaults through [] calls" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p['nonexistent'].should be_false
    p['nonexistent', true].should be_true
    p['nonexistent', true].should_not be_an_instance_of Hash
    p['nonexistent', {}].should be_an_instance_of Hash
  end
  
  it "should give access to the rack.session env" do
    p= Orange::Packet.new(Orange::Core.new, {'rack.session' => {'foo' => 'banana'}})
    p.session.should have_key 'foo'
    p.session.should have_key 'flash'
  end
  
  it "should give always have a flash" do
    p= Orange::Packet.new(Orange::Core.new, {'rack.session' => {}})
    p.session.should have_key 'flash'
    p.flash.should == {}
  end
  
  it "should destruct a flash value upon reading" do    
    p= Orange::Packet.new(Orange::Core.new, {'rack.session' => {}})
    p.session.should have_key 'flash'
    p.session["flash"]["foo"] = "bar"
    p.flash("foo").should == "bar"
    p.flash("foo").should be_nil
    p.session["flash"].should_not have_key("foo")
    p.flash("foo", "bar")
    p.flash("foo").should == "bar"
    p.flash("foo").should be_nil
    p.session["flash"].should_not have_key("foo")
    p.flash["foo"] = "bar"
    p.flash("foo").should == "bar"
    p.flash("foo").should be_nil
    p.flash.should_not have_key("foo")
  end
  
  it "should give headers by combining :headers with defaults" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.headers.should == p[:headers, {}].with_defaults(Orange::Packet::DEFAULT_HEADERS)
  end
  
  it "should allow setting headers via header(key, val)" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.header('Content-Type', 'text/plain')
    p.headers['Content-Type'].should == 'text/plain'
  end
  
  it "should allow adding headers with add_header" do
    p1= Orange::Packet.new(Orange::Core.new, {})
    p2= Orange::Packet.new(Orange::Core.new, {})
    p1.add_header('Content-Type', 'text/plain')
    p2.header('Content-Type', 'text/plain')
    p1.headers['Content-Type'].should == p2.headers['Content-Type']
  end
  
  it "should give access to the core object via orange" do
    c= Orange::Core.new
    p= Orange::Packet.new(c, {})
    p.orange.should equal c
    p.orange.should be_an_instance_of(Orange::Core)
  end
  
  it "should create a triple according to rack standards on #finish" do
    p= Orange::Packet.new(Orange::Core.new, {})
    fin = p.finish
    fin[0].should be_a_kind_of Integer
    fin[1].should be_a_kind_of Hash
    fin[2].should be_a_kind_of Array
  end
  
  it "should give self when using packet" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.packet.should equal p
  end
  
  it "should mixin when calling mixin" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.should_not respond_to(:pulp_orange_two)
    Orange::Packet.mixin MockPulpOrange2
    p.should respond_to(:pulp_orange_two)
  end
  
  it "should raise an error if no router set" do
    p= Orange::Packet.new(Orange::Core.new, {})
    lambda{
      p.route
    }.should raise_error(RuntimeError, 'Router not found')
  end
  
  it "should pass self to assigned router's route method" do
    class MockDeathRouter
      def route(p); raise "die, die, death, #{p[:lame]}"; end
    end
    p= Orange::Packet.new(Orange::Core.new, {})
    p['route.router'] = MockDeathRouter.new
    p[:lame] = 'death'
    lambda{
      p.route
    }.should_not raise_error(RuntimeError, 'Router not found')
    lambda{
      p.route
    }.should raise_error(RuntimeError, 'die, die, death, death')
  end
  
  it "should give a request object" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.request.should be_an_instance_of Rack::Request
  end
  
  it "should store method matchers for extending method_missing handlers" do
    class Orange::Packet 
      meta_methods(/pretend_method_we_dont_want/) do |match, args|
        "my mock meta method"
      end
      
      meta_methods(/pretend_method_we_dont_want(\w+)/) do |match, args|
        "my mock meta method"
      end
    end
    p= Orange::Packet.new(Orange::Core.new, {})
    p.matchers.size.should >= 2
  end
  
  it "should have method_missing capabilities" do
    p= Orange::Packet.new(Orange::Core.new, {})
    p.should respond_to(:method_missing)
    lambda {
      p.my_mock_meta_method
      p.mock_meta_test
      p.mock_meta_test_with_args
    }.should raise_error(NoMethodError)
    class Orange::Packet 
      meta_methods(/my_mock_meta_method/) do 
        "my mock meta method"
      end
      
      meta_methods(/mock_meta_(\w+)/) do |packet, match|
        "my mock #{match[1]} method"
      end
      
      meta_methods(/mock_meta_(\w+)_with_args/) do |packet, match, args|
        "my mock #{match[1]} method args0 = #{args[0]}"
      end
    end
    lambda {
      p.my_mock_meta_method
      p.mock_meta_test
      p.mock_meta_test_with_args 'test'
    }.should_not raise_error(NoMethodError)
    p.my_mock_meta_method.should == "my mock meta method"
    p.mock_meta_test.should == "my mock test method"
    p.mock_meta_test_with_args('test').should == "my mock test method args0 = test"
  end
end