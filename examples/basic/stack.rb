require 'rack/builder'
require 'rack/abstract_format'
require '../../lib/orange'

require 'rack/openid'
require 'openid_dm_store'

class Main < Orange::Application
  stack do
    
    use Rack::CommonLogger
    use Rack::Reloader
    use Rack::MethodOverride
    use Rack::Session::Cookie, :secret => 'orange_secret'

    auto_reload!
    use_exceptions
    stack Orange::Middleware::Globals
    stack Orange::Middleware::Loader
    prerouting :multi => false
    stack Orange::Middleware::Database
    stack Orange::Middleware::SiteLoad
    stack Orange::Middleware::RadiusParser
    stack Orange::Middleware::Template
    

    use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
    stack Orange::Middleware::AccessControl, :single_user => false
    
    restful_routing
    stack Orange::Middleware::FlexRouter
    stack Orange::Middleware::FourOhFour
    load Tester.new
    run Main.new(orange)
  end
end