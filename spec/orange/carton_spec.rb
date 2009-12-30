require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Orange::Carton do
  it "should call property with :id, Serial on #self.id" do
    MockCartonBlank.should_receive(:property).with(:id, DataMapper::Types::Serial)
    MockCartonBlank.id
  end
  
  it "should call self.init after calling id" do
    MockCartonBlankTwo.should_receive(:init)
    MockCartonBlankTwo.id
  end
  
  it "should give form properties" do
    MockCarton.form_props(:live).length.should >= 1
    MockCarton.form_props(:admin).length.should >= 2
    MockCarton.form_props(:orange).length.should >= 3
    MockCarton.form_props(:banana).should have(0).items
  end
  
  it "should call instance eval on admin block" do
    MockCartonBlank.should_receive(:instance_eval)
    MockCartonBlank.admin {}
  end
  
  it "should call instance eval on orange block" do
    MockCartonBlank.should_receive(:instance_eval)
    MockCartonBlank.orange {}
  end
  
  it "should call instance eval on front block" do
    MockCartonBlank.should_receive(:instance_eval)
    MockCartonBlank.front {}
  end
  
  it "should change props when calling front_property" do
    lambda {
      MockCarton.front_property :foo, String
    }.should change(MockCarton, :form_props)
    
  end
  
  it "should change admin props when calling admin_property (but not front props)" do
    old_props = MockCarton.form_props(:admin)
    lambda {
      MockCarton.admin_property :foo, String
    }.should_not change(MockCarton, :form_props)
    old_props.should_not == MockCarton.form_props(:admin)
  end
  
  it "should change orange props when calling orange_property (but not front/admin props)" do
    admin_props = MockCarton.form_props(:admin)
    old_props = MockCarton.form_props(:orange)
    lambda {
      MockCarton.orange_property :foo, String
    }.should_not change(MockCarton, :form_props)
    admin_props.should == MockCarton.form_props(:admin)
    old_props.should_not == MockCarton.form_props(:orange)
  end
  
  it "should change the levels var when using front block" do
    MockCartonBlank.should_receive(:test_levels){|me| me.levels.should include(:live)}
    MockCartonBlank.front{ test_levels(self) }
    MockCartonBlank.levels.should == false
  end
  
  it "should change the levels var when using admin block" do
    MockCartonBlank.should_receive(:test_levels){|me| 
      me.levels.should_not include(:front)
      me.levels.should include(:admin)
    }
    MockCartonBlank.admin{ test_levels(self) }
    MockCartonBlank.levels.should == false
  end
  
  it "should change the levels var when using orange block" do
    MockCartonBlank.should_receive(:test_levels){|me| 
      me.levels.should_not include(:front)
      me.levels.should_not include(:admin)
      me.levels.should include(:orange)
    }
    MockCartonBlank.orange{ test_levels(self) }
    MockCartonBlank.levels.should == false
  end
  
  it "should have a front property after calling #front" do
    front = MockCarton.scaffold_properties.select{|i| i[:name] == :front}
    front.should have_at_least(1).items
    front.first[:levels].should include(:live)
  end 
  
  it "should have an admin property after calling #admin" do
    front = MockCarton.scaffold_properties.select{|i| i[:name] == :admin}
    front.should have_at_least(1).items
    front.first[:levels].should_not include(:live)
    front.first[:levels].should include(:admin)
  end
  
  it "should have an orange property after calling #orange" do
    front = MockCarton.scaffold_properties.select{|i| i[:name] == :orange}
    front.should have_at_least(1).items
    front.first[:levels].should_not include(:live)
    front.first[:levels].should_not include(:admin)
    front.first[:levels].should include(:orange)
  end
  
  it "should call property on title" do
    MockCarton.should_receive(:property).with(an_instance_of(Symbol), String, anything())
    MockCarton.title(:wibble)
  end
  
  it "should call property on text" do
    MockCarton.should_receive(:property).with(an_instance_of(Symbol), String, anything())
    MockCarton.text(:wobble)
  end

  it "should call property on string" do
    MockCarton.should_receive(:property).with(an_instance_of(Symbol), String, anything())
    MockCarton.string(:wubble)
  end
  
  it "should call property on fulltext" do
    MockCarton.should_receive(:property).with(an_instance_of(Symbol), DataMapper::Types::Text, anything())
    MockCarton.fulltext(:cudge)
  end
  
  it "should define a constant (resource class)" do
    lambda{
      MockCartonBlankTwo_Resource.nil?
    }.should raise_error(NameError)
    MockCartonBlankTwo.as_resource
    lambda{
      MockCartonBlankTwo_Resource.nil?
    }.should_not raise_error
  end
end