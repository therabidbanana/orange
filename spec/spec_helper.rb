require 'spec/mock/mock_app'
require 'rack/test'

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
end