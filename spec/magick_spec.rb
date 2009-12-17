require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Black::Magick" do
  it "should be spec'ed"
end

describe "Orange::Options" do
  it "should give a hash on hash" do
    Orange::Options.new.hash.should be_an_instance_of(Hash)
  end
  
  it "should accept hash key options" do
    hash1 = Orange::Options.new(:one => '1', :two => ['foo']).hash
    hash2 = Orange::Options.new(:one => '1').hash
    hash3 = Orange::Options.new({:one => '1', :two => ['foo']}).hash
    hash4 = Orange::Options.new({:one => '1'}).hash
    hash5 = Orange::Options.new(1,2, {:one => '1', :two => ['foo']}).hash
    hash6 = Orange::Options.new(1,2, {:one => '1'}).hash
    [hash2, hash4, hash6].each{ |hash|
      hash.should have_key(:one)
      hash.should_not have_key(:three)
      hash[:one].should == '1'
    }
    [hash1, hash3, hash5].each{ |hash|
      hash.should have_key(:one)
      hash.should have_key(:two)
      hash.should_not have_key(:three)
      hash[:one].should == '1'
      hash[:two].should == ['foo']
    }
  end
  
  it "should accept block options" do
    hash = Orange::Options.new {
      one '1'
      two ['foo']
    }.hash
    hash.should have_key(:one)
    hash.should have_key(:two)
    hash.should_not have_key(:three)
    hash[:one].should == '1'
    hash[:two].should == ['foo']
  end
  
  it "should accept both kinds of options" do
    hash = Orange::Options.new(:one => '1'){
      two ['foo']
    }.hash
    
    hash.should have_key(:one)
    hash.should have_key(:two)
    hash.should_not have_key(:three)
    hash[:one].should == '1'
    hash[:two].should == ['foo']
  end
  
  it "should override hash key options with block options" do
    hash = Orange::Options.new(:one => '1', :two => [:baz]){
      two ['foo']
    }.hash
    
    hash.should have_key(:one)
    hash.should have_key(:two)
    hash.should_not have_key(:three)
    hash[:one].should == '1'
    hash[:two].should == ['foo']
  end
end