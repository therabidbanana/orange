$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'orange'

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