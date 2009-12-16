require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Application do
  before(:all) do
    class MockApplication
      set :banana, 'foo'
      attr_accessor :quux, :wibble
      def init
        opts[:init] = true
        @quux = true
      end
      def stack_init
        opts[:stack_init] = true
        @wibble = true
      end
    end
  end
  
  def app
    MockApplication.app
  end
  
  it "should be a subclass of Orange::Application" do
    MockApplication.new(Orange::Core.new).should be_a_kind_of(Orange::Application)
  end
  
  it "should have a stack method" do
    MockApplication.should respond_to(:stack)
  end
  
  it "should have a different app stack after using stack method" do
    lambda {
      MockApplication.stack do
      end
    }.should change(MockApplication, :app)
  end

  it "should respond to the app method" do
    MockApplication.should respond_to(:app)
  end
  
  it "should return an Orange::Stack with the app method" do
    MockApplication.stack do
    end
    MockApplication.app.should be_an_instance_of(Orange::Stack)
  end
  
  it "should be able to set options" do
    MockApplication.set(:test4, Time.now.to_f-5)
    opts_test4 = MockApplication.opts[:test4]
    MockApplication.set(:test4, Time.now.to_f)
    MockApplication.opts[:test4].should_not == opts_test4
    MockApplication.opts[:banana].should == 'foo'
  end
  
  it "should be able to accept instance option setting" do
    x= MockApplication.new(Orange::Core.new, {:test => 'go'}){
      baz 'bar'
    }
    x.opts.should have_key(:baz)
    x.opts.should have_key(:banana)
    x.opts[:baz].should == 'bar'
    x.opts[:test].should == 'go'
  end
  
  it "should override class variables with instance ones" do
    x= MockApplication.new(Orange::Core.new)
    y= MockApplication.new(Orange::Core.new){
      banana 'bar'
    }
    x.opts.should have_key(:banana)
    y.opts.should have_key(:banana)
    x.opts[:banana].should == 'foo'
    y.opts[:banana].should == 'bar'
    x.opts[:banana].should_not == y.opts[:banana]
  end
  
  it "should be able to access options via #opts" do
    x= MockApplication.new(Orange::Core.new){
      baz 'bar'
    }
    x.opts.should be_an_instance_of(Hash)
    x.opts.should respond_to(:[])
    x.opts.should have_key(:baz)
    x.opts[:baz].should == 'bar'
  end
  
  it "should call init after being initialized" do
    x=MockApplication.new(Orange::Core.new){
      init false
    }
    x.opts[:init].should be_true
    x.quux.should be_true
  end
  
  it "should call stack_init after stack loaded" do
    c = Orange::Core.new
    app = MockApplication.new(c){
      stack_init false
    }
    c.fire(:stack_loaded, false) # Falsify the stack_load call
    app.opts[:stack_init].should be_true
    app.wibble.should be_true
  end
  
  it "should raise a default error if route isn't redefined" do
    x= MockApplication.new(Orange::Core.new)
    lambda{ 
      x.route(Orange::Packet.new(x.orange, {})) 
    }.should raise_error(Exception, 'default response from Orange::Application.route')
  end
  
  it "should return the orange core on #orange" do
    c = Orange::Core.new
    x= MockApplication.new(c)
    x.orange.should eql(c)
  end
  
  it "should change the core on #set_core(orange_core)" do
    c1 = Orange::Core.new
    c2 = Orange::Core.new
    x= MockApplication.new(c1)
    c1.should_not eql(c2)
    lambda {
      x.set_core(c2)
    }.should change(x, :orange)
  end
  
  it "should respond correctly to call" do
    x= MockApplication.new(Orange::Core.new)
    lambda{
      x.call({})
    }.should raise_error(Exception, 'default response from Orange::Application.route')
    r = TestRouter.new
    lambda{
      x.call({'orange.env' => {'route.router' => r}})
    }.should change(r, :x)
  end
  
  it "should auto initialize the self.opts" do
    lambda{
      MockApplication2.opts
    }.should_not raise_error
  end
    
end