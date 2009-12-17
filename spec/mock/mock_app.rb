require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'orange'
require 'rack/abstract_format'

class MockApplication < Orange::Application
  
end

class MockApplication2 < Orange::Application
  
end

class MockExitware
  def call(env)
    raise 'Mock Exitware'
  end
end