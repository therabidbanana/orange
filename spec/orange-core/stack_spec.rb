require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Stack do
  before(:all) do
    # allow deep introspection into rack builder
    class Rack::Builder 
      attr_accessor :ins
      # introspection into the Builder object's list of items
      # builder uses Proc magic to chain the middleware together,
      # so we undo it.
      def ins_no_procs
        @ins.map{|x| x.instance_of?(Proc)? x.call(nil) : x }
      end
    end
    class Orange::Stack 
      attr_accessor :build
      def middlewarez
        build.ins_no_procs
      end
    end
  end
  
  def app
    MockApplication.app
  end
  
  it "should create a default stack when called by Application" do
    MockApplication2.app.should be_an_instance_of(Orange::Stack)
    MockApplication2.app.main_app.should be_a_kind_of(Orange::Application)
  end
  
  it "should have access to core" do
    MockApplication.app.orange.should be_an_instance_of(Orange::Core)
  end
  
  it "should have access to the main application instance" do
    MockApplication2.app.main_app.should be_an_instance_of(MockApplication2)
  end
  
  it "should have the run function" do
    x= Orange::Stack.new do
      run MockExitware.new
    end
    lambda {
      x.call({:test => 'middlewarez'})
    }.should raise_error(RuntimeError, "Mock Exitware")
  end
  
  it "should accept a core object in initialization" do
    c = Orange::Core.new
    c2 = Orange::Core.new
    
    x = Orange::Stack.new(nil, c) do
      run MockExitware.new
    end
    x.orange.should equal(c)
    x.orange.should_not equal(c2)
  end
  
  it "should have the use function" do
    x= Orange::Stack.new do
      use MockMiddleware
      run MockExitware.new
    end
    lambda {
      x.call({:test => 'middlewarez'})
    }.should raise_error(RuntimeError, "I'm in ur middlewarez")
    lambda {
      x.call({:test => 'middlewarez'})
    }.should_not raise_error(RuntimeError, "It's over 9000")
  end
  
  it "should have the stack function" do
    x= Orange::Stack.new do
      stack MockOrangeBasedMiddleware
      run MockExitware.new
    end
    lambda {
      x.call({:test => 'middlewarez'})
    }.should raise_error(RuntimeError, "It's over 9000 Orange::Cores!")
  end
  
  it "should respect order of stack/use cases" do
    x= Orange::Stack.new do
      use MockMiddleware
      stack MockOrangeBasedMiddleware
      run MockExitware.new
    end
    y= Orange::Stack.new do
      stack MockOrangeBasedMiddleware
      use MockMiddleware
      run MockExitware.new
    end
    lambda {
      x.call({:test => 'middlewarez'})
    }.should raise_error(RuntimeError, "I'm in ur middlewarez")
    lambda {
      y.call({:test => 'middlewarez'})
    }.should raise_error(RuntimeError, "It's over 9000 Orange::Cores!")
  end
  
  it "should load a resource when using load" do
    x= Orange::Stack.new
    x.load(MockResource.new, :test)
    x.orange[:test].mock_method.should == 'MockResource#mock_method'
  end
  
  it "should not rebuild stack if auto_reload not set" do
    x= Orange::Stack.new do
      run MockExitware.new
    end
    x.app.should eql(x.app)
  end
  
  it "should rebuild stack if auto_reload! set" do
    x= Orange::Stack.new do
      auto_reload!
      use MockMiddleware
      run MockExitware.new
    end
    x.app.should_not eql(x.app)
  end
  
  it "should include ShowExceptions in stack if use_exceptions called" do
    x= Orange::Stack.new do
      use_exceptions
      run MockExitware.new
    end
    mapped = x.middlewarez
    mapped.should_not eql([])
    mapped.select{|x| x.instance_of?(Orange::Middleware::ShowExceptions)}.should_not be_empty
    mapped.select{|x| x.instance_of?(Orange::Middleware::ShowExceptions)}.should have(1).items
  end
  
  it "should add middleware when calling prerouting" do
    x= Orange::Stack.new do
      no_recapture
      run MockExitware.new
    end
    x.middlewarez.should have(1).middlewares
    x.prerouting
    x.middlewarez.should have(9).middlewares
    x.middlewarez.select{|y| y.instance_of?(Rack::AbstractFormat)}.should_not be_empty
    x.middlewarez.select{|y| y.instance_of?(Orange::Middleware::RouteSite)}.should_not be_empty
  end
  
  it "should add one less middleware when calling prerouting with opt :no_abstract_format" do
    x= Orange::Stack.new do
      no_recapture
      run MockExitware.new
    end
    x.middlewarez.should have(1).middlewares
    x.prerouting(:no_abstract_format => true)
    x.middlewarez.should have(8).middlewares
    x.middlewarez.select{|y| y.instance_of?(Rack::AbstractFormat)}.should be_empty
    x.middlewarez.select{|y| y.instance_of?(Orange::Middleware::RouteSite)}.should_not be_empty
  end
  
  
  it "should have not have extra middleware for a default stack" do
    x= Orange::Stack.new MockApplication
    x.middlewarez.should have(1).middlewares
  end
    
  # it "should not include Rack::OpenID unless openid_access_control enabled" do
  #     defined?(Rack::OpenID).should be_nil
  #     x= Orange::Stack.new do
  #       openid_access_control
  #       run MockExitware.new
  #     end
  #     defined?(Rack::OpenID).should == "constant"
  #   end
  
  # it "should add middleware when calling openid_access_control" do
  #     x= Orange::Stack.new do
  #       no_recapture
  #       run MockExitware.new
  #     end
  #     x.middlewarez.should have(1).middlewares
  #     x.openid_access_control
  #     x.middlewarez.should have(3).middlewares
  #     x.middlewarez.select{|y| y.instance_of?(Rack::OpenID)}.should_not be_empty
  #     x.middlewarez.select{|y| y.instance_of?(Orange::Middleware::AccessControl)}.should_not be_empty
  #   end
  
  it "should include a module into Orange::Packet on add_pulp" do
    x= Orange::Stack.new
    p= Orange::Packet.new(Orange::Core.new, {})
    p.should_not respond_to(:my_new_mock_method)
    x.add_pulp(MockPulp)
    p.should respond_to(:my_new_mock_method)
    p.should be_a_kind_of(MockPulp)
  end
  
end