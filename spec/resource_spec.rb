require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Resource do
  it "should allow options" do
    r= Orange::Resource.new(:opt_1 => true){ opt_2 true }
    r.options[:opt_1].should == true
    r.options[:opt_2].should == true
    r.options.should have_key(:opt_1)
    r.options.should_not have_key(:opt_3)
  end
  
  it "should accept an orange core on set_orange" do
    c= Orange::Core.new 
    r= Orange::Resource.new
    r.set_orange(c, :name)
    r.orange.should equal(c)
    r.orange.should be_a_kind_of(Orange::Core)
  end
  
  it "should call afterLoad after calling set_orange" do
    c= Orange::Core.new 
    r= MockResource.new
    r.options.should_not have_key(:mocked)
    r.set_orange(c, :name)
    r.options.should have_key(:mocked)
    r.options[:mocked].should == true
  end
  
  it "should set the orange_name after calling set_orange" do
    c= Orange::Core.new 
    r= Orange::Resource.new
    r2= Orange::Resource.new
    r.set_orange(c, :name)
    r2.set_orange(c, 'name')
    r.orange_name.should == :name
    r2.orange_name.should_not == :name
    r2.orange_name.should == 'name'
  end
  
  it "should return self after set_orange" do
    c= Orange::Core.new 
    r= Orange::Resource.new
    me = r.set_orange(c, :name)
    me.should equal r
  end
  
  it "should return an error if setting orange on a class" do
    lambda {
      Orange::Resource.set_orange(Orange::Core.new, :mock)
    }.should raise_error(RuntimeError, "instantiate the resource before calling set orange")
  end
  
  it "should give access to the core through orange" do
    c= Orange::Core.new 
    r= Orange::Resource.new
    r.set_orange(c, :name)
    r.orange.should equal(c)
    r.orange.should be_a_kind_of(Orange::Core)
  end
  
  it "should respond to routable" do
    r = Orange::Resource.new
    r.should respond_to(:routable)
    r.routable.should be_false
  end
  
  it "should return an empty string on calling view" do
    r = Orange::Resource.new
    r.view.should == ''
    r.view(Orange::Packet.new(Orange::Core.new, {})).should == ''
  end
  
  it "should accept an options hash to view" do
    p = Orange::Packet.new(Orange::Core.new, {})
    r = Orange::Resource.new
    lambda{
      r.view(p, :opts => 'foo', :test => 'bar')
    }.should_not raise_error
  end
  
  it "should give access to the orange name attribute" do
    c= Orange::Core.new 
    r= Orange::Resource.new
    r.set_orange(c, :name)
    r.orange_name.should == :name
  end
  
  
end