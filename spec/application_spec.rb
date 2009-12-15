describe MockApplication do
  it "should inherit a default stack" do
    MockApplication.app.should be_an_instance_of(Orange::Stack)
    MockApplication.app.should 
  end
end