describe MockApplication do
  
  def app
    MockApplication.app
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
  
  
end