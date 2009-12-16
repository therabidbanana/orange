describe "MockApplication Stack" do
  def app
    MockApplication.app
  end
  
  it "should inherit a default stack" do
    MockApplication.app.should be_an_instance_of(Orange::Stack)
    get '/'
    
  end
  
  it "should have access to core" do
    MockApplication.app.orange.should be_an_instance_of(Orange::Core)
  end
  
  it "should have access to the main application instance" do
    MockApplication.app.main_app.should_not be_nil
  end
  
end