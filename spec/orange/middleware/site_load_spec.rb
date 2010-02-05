describe Orange::Middleware::SiteLoad do
  it "should load Orange::SiteResource when used in stack" do
    c = Orange::Core.new
    c.should_receive(:load).with(an_instance_of(Orange::SiteResource), an_instance_of(Symbol))
    app = Orange::Middleware::SiteLoad.new(nil, c)
    
  end
  
  it "should load the site object into the packet, if available" do
    Orange::Site.should_receive(:first).with(an_instance_of(Hash)).and_return('foo')
    app = Orange::Middleware::SiteLoad.new(return_env_app, Orange::Core.new)
    ret = app.call({})
    ret[0]['orange.env'].should have_key('site')
    ret[0]['orange.env']['site'].should == 'foo'
  end
  
  it "should create a new site object, if one doesn't exist" do
    Orange::Site.should_receive(:first).with(an_instance_of(Hash)).and_return(false)
    m = mock("site")
    Orange::Site.should_receive(:new).with(an_instance_of(Hash)).and_return(m)
    m.should_receive(:save).and_return(true)
    app = Orange::Middleware::SiteLoad.new(return_env_app, Orange::Core.new)
    ret = app.call({})
    ret[0]['orange.env'].should have_key('site')
  end
end