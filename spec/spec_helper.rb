require 'spec/mock/mock_app'
require 'spec/mock/mock_pulp'
require 'spec/mock/mock_core'
require 'spec/mock/mock_mixins'
require 'spec/mock/mock_router'
require 'spec/mock/mock_resource'
require 'spec/mock/mock_middleware'
require 'rack/test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'orange'
Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
end