require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Core do
  before(:all) do
    class Orange::Core; attr_reader :resources, :events, :file; end;
  end
  
  it "should allow core mixin via class mixin method" do
    c= Orange::Core.new
    c.should_not respond_to(:mixin_core_one)
    Orange::Core.mixin MockMixinCore1
    c2= Orange::Core.new
    c.should respond_to(:mixin_core_one)
    c2.should respond_to(:mixin_core_one)
  end
  
  it "should allow pulp mixin via class pulp method" do
    c= Orange::Core.new
    p= Orange::Packet.new(c, {})
    p.should_not respond_to(:pulp_core_one)
    Orange::Core.add_pulp MockPulpCore1
    p2= Orange::Packet.new(c, {})
    p.should respond_to(:pulp_core_one)
    p2.should respond_to(:pulp_core_one)
  end
  
  it "should allow core mixin via instance mixin method" do
    c= Orange::Core.new
    c.should_not respond_to(:mixin_core_two)
    c.mixin MockMixinCore2
    c2= Orange::Core.new
    c.should respond_to(:mixin_core_two)
    c2.should respond_to(:mixin_core_two)
  end
  
  it "should allow pulp mixin via instance pulp method" do
    c= Orange::Core.new
    p= Orange::Packet.new(c, {})
    p.should_not respond_to(:pulp_core_two)
    c.add_pulp MockPulpCore2
    p2= Orange::Packet.new(c, {})
    p.should respond_to(:pulp_core_two)
    p2.should respond_to(:pulp_core_two)
  end
  
  it "should have three contexts by default" do
    Orange::Core::DEFAULT_CORE_OPTIONS.should have_key(:contexts)
    Orange::Core::DEFAULT_CORE_OPTIONS[:contexts].should have(3).items
  end
  
  it "should default to live context" do
    Orange::Core::DEFAULT_CORE_OPTIONS.should have_key(:default_context)
    Orange::Core::DEFAULT_CORE_OPTIONS[:default_context].should == :live
  end
  
  it "should load at least two resources by default" do
    c= Orange::Core.new
    c.resources.size.should >= 2
    c.loaded?(:mapper).should be_true
    c.loaded?(:parser).should be_true
  end
  
  it "should have two events by default" do
    c= Orange::Core.new
    c.events.should have(2).events
    c.events.should have_key(:stack_reloading)
    c.events.should have_key(:stack_loaded)
  end
  
  it "should return a directory that contains core.rb when calling core_dir" do
    c= Orange::Core.new
    c.core_dir.should match(/orange-core$/)
    File.should exist(File.join(c.core_dir, 'core.rb'))
    File.should exist(File.join(c.core_dir, 'stack.rb'))
    File.should exist(File.join(c.core_dir, 'application.rb'))
    File.should exist(File.join(c.core_dir, 'carton.rb'))
    File.should exist(File.join(c.core_dir, 'views'))
    File.should exist(File.join(c.core_dir, 'templates'))
    File.should exist(File.join(c.core_dir, 'assets'))
  end
  
  it "should return the directory of the super class when calling core_dir on subclass" do
    c= MockCoreSubclass.new
    c.core_dir.should match(/orange-core$/)
    File.should exist(File.join(c.core_dir, 'core.rb'))
    File.should exist(File.join(c.core_dir, 'stack.rb'))
    File.should exist(File.join(c.core_dir, 'application.rb'))
    File.should exist(File.join(c.core_dir, 'carton.rb'))
    File.should exist(File.join(c.core_dir, 'views'))
    File.should exist(File.join(c.core_dir, 'templates'))
    File.should exist(File.join(c.core_dir, 'assets'))
  end
  
  it "should call afterLoad after init" do
    c1= MockCoreSubclass.new
    class MockCoreSubclass
      def afterLoad
        options[:called_afterload_for_subclass] = true
      end
    end
    c2= MockCoreSubclass.new
    c1.options[:called_afterload_for_subclass].should_not == c2.options[:called_afterload_for_subclass]
    c1.options.should_not have_key(:called_afterload_for_subclass)
    c2.options.should have_key(:called_afterload_for_subclass)
    c2.options[:called_afterload_for_subclass].should be_true
  end
  
  it "should allow changing of default core_dir" do
    c= Orange::Core.new
    c.options[:core_dir] = "/non/existent/dir"
    c.core_dir.should_not == File.dirname(c.file)
    c.core_dir.should == "/non/existent/dir"
    File.should exist(File.join(File.dirname(c.file), 'core.rb'))
  end
  
  it "should return Dir.pwd for app_dir by default" do
    Orange::Core.new.app_dir.should == Dir.pwd
  end
  
  it "should return assigned app_dir if option set" do
    c= Orange::Core.new
    c.options[:app_dir] = "/non/existent/dir"
    c.app_dir.should_not == Dir.pwd
    c.app_dir.should == "/non/existent/dir"
  end
  
  it "should return assigned app_dir with extra path if args passed" do
    c= Orange::Core.new
    c.options[:app_dir] = "/non/existent/dir"
    c.app_dir('foo', 'bar').should_not == c.app_dir
    c.app_dir('foo', 'bar').should == "/non/existent/dir/foo/bar"
  end
  
  it "should allow options" do
    c= Orange::Core.new(:opt_1 => true){ opt_2 true }
    c.options[:opt_1].should == true
    c.options[:opt_2].should == true
    c.options.should have_key(:opt_1)
    c.options.should_not have_key(:opt_3)
  end
  
  it "should load a resource when passed resource instance" do
    c= Orange::Core.new
    c.load(MockResource.new, :mock_one)
    c.resources.should have_key(:mock_one)
    c.resources[:mock_one].should be_an_instance_of(MockResource)
    
  end
  
  it "should default to lowercase resource name to symbol as resource short name" do
    c= Orange::Core.new
    c.load(MockResource.new)
    sym = MockResource.to_s.gsub(/::/, '_').downcase.to_sym
    c.resources.should have_key(sym)
    c.should be_loaded(sym)
  end
  
  it "should say a resource is loaded after calling load for resource" do
    c= Orange::Core.new
    c.load(MockResource.new, :mock_one)
    c.should be_loaded(:mock_one)
    c.resources.should have_key(:mock_one)
  end
  
  it "should return self on orange" do
    c= Orange::Core.new
    c.orange.should eql(c)
  end
  
  it "should add event to events list when register called" do
    c= Orange::Core.new
    c.register(:mock_event) {|x| x }
    c.events.should_not be_empty
    c.events.should have_key(:mock_event)
    c.events[:mock_event].should be_an_instance_of(Array)
    c.events[:mock_event].should have(1).callback
    c.register(:mock_event) {|x| x }
    c.events[:mock_event].should have(2).callbacks
  end
  
  it "should add events in specified order when registered with position" do
    c= Orange::Core.new
    c.register(:mock_event, 5) {|x| '5' }
    c.events.should_not be_empty
    c.events.should have_key(:mock_event)
    c.events[:mock_event].compact.should have(1).callback
    5.times{ |i| c.events[:mock_event][i].should be_nil }
    c.register(:mock_event, 2) {|x| '2' }
    c.events[:mock_event].compact.should have(2).callbacks
    c.events[:mock_event][2].call(nil).should eql '2'
    c.events[:mock_event][6].call(nil).should eql '5'
    c.events[:mock_event].compact.first.call(nil).should eql '2'
    c.events[:mock_event].compact.last.call(nil).should eql '5'
    c.register(:mock_event, 5) {|x| '5.2' }
    c.events[:mock_event].compact.should have(3).callbacks
    c.events[:mock_event][2].call(nil).should eql '2'
    c.events[:mock_event][5].call(nil).should eql '5.2'
    c.events[:mock_event][7].call(nil).should eql '5'
    c.events[:mock_event].compact.first.call(nil).should eql '2'
    c.events[:mock_event].compact.last.call(nil).should eql '5'
  end
  
  it "should fire registered events when fire called" do
    class OtherMockCore < Orange::Core 
      attr_accessor :mock_counter
      def afterLoad
        @mock_counter = 0
      end
    end
    c= OtherMockCore.new
    c.mock_counter.should == 0
    c.register(:mock_event) {|i| c.mock_counter += i }
    c.register(:mock_event_two) {|i| c.mock_counter -= i }
    c.mock_counter.should == 0
    c.fire(:mock_event, 3)
    c.mock_counter.should_not == 0
    c.mock_counter.should == 3
    c.fire(:mock_event_two, 2)
    c.mock_counter.should_not == 0
    c.mock_counter.should == 1
    c.register(:mock_event) {|i| c.mock_counter += i }
    c.fire(:mock_event, 3)
    c.mock_counter.should_not == 1
    c.mock_counter.should == 7
  end
  
  it "should have an options hash" do
    Orange::Core.new.options.should be_an_instance_of(Hash)
  end
  
  it "should allow access to the resources via []" do
    c= Orange::Core.new
    c.load(MockResource.new, :mock)
    c[:mock].should be_an_instance_of(MockResource)
    c[:mock].should be_an_kind_of(Orange::Resource)
    c[:mock].mock_method.should eql 'MockResource#mock_method'
  end
  
  it "should have option to silently ignore resource calls" do
    c= Orange::Core.new
    lambda {
      c[:mock].test
    }.should raise_error
    lambda {
      c[:mock, true].test
    }.should_not raise_error
  end
end