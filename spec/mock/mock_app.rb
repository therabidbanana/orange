require 'rubygems'
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