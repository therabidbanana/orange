require 'rack/builder'
require 'rack/abstract_format'
require '../../lib/orange'

require 'rack/openid'
require 'openid_dm_store'

class Main < Orange::Application
  stack do
    orange.options[:development_mode] = true
    orange.options[:ping_fm_key] = "2267dc099645616acfc8d8f8373e5703-1257559701"
    
    use Rack::CommonLogger
    use Rack::Reloader
    use Rack::MethodOverride
    use Rack::Session::Cookie, :secret => 'orange_secret'

    auto_reload!
    use_exceptions
    
    use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
    prerouting :multi => false

    routing :single_user => false
    
    postrouting
    load Tester.new
    run Main.new(orange)
  end
end