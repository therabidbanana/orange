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
    prerouting :multi => false    

    use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
    routing :single_user => false
    
    postrouting
    load Tester.new
    run Main.new(orange)
  end
end