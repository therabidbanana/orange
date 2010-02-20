$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'orange-core'

require 'mock/mock_app'
require 'mock/mock_pulp'
require 'mock/mock_core'
require 'mock/mock_carton'
require 'mock/mock_model_resource'
require 'mock/mock_mixins'
require 'mock/mock_router'
require 'mock/mock_resource'
require 'mock/mock_middleware'
require 'rack/test'


Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
end

def mock_post
  p= mock("request", :null_object => true)
  p.stub!(:post?).and_return(true)
  p.stub!(:params).and_return({})
  p
end

def mock_delete
  p= mock("request", :null_object => true)
  p.stub!(:delete?).and_return(true)
  p.stub!(:params).and_return({})
  p
end

def empty_packet(c = Orange::Core.new)
  Orange::Packet.new(c, {})
end

def packet_finish_app
  lambda { |env|
    Orange::Packet.new(env).finish
  }
end

def return_env_app
  lambda { |env|
    [env, 200, ["ok"]]
  }
end