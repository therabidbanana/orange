require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Orange::AdminResource do
  before(:all) do
  end
  it "should have a function for returning list of links" do
    a = Orange::AdminResource.new
    a.set_orange(Orange::Core.new, :admin)
    a.links(empty_packet)
  end
  it "should be have an add_link function" do
    a = Orange::AdminResource.new
    a.set_orange(Orange::Core.new, :admin)
    a.add_link('Content', {})
  end
end