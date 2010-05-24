require 'rack/builder'
require 'rack/abstract_format'
require '../../lib/orange'

require 'rack/openid'
require 'openid_dm_store'

class Main < Orange::Application
  stack do
    orange.options[:development_mode] = true
    orange.options[:contexts] = [:preview, :live, :admin, :orange]
    
    use Rack::CommonLogger
    use Rack::MethodOverride
    use Rack::Session::Cookie, :secret => 'orange_secret'

    auto_reload!
    use_exceptions
    
    use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
    prerouting :multi => false, :locked => [:preview, :admin, :orange], :contexts => [:preview, :live, :admin, :orange]

    routing :single_user => false, :exposed_actions => {:admin => :all, :orange => :all, :preview => {:all => :show}, :live => {:all => :show, :contactforms => [:mailer], :members => [:login, :logout, :profile, :register]}}
    postrouting
    
    responders
    run Main.new(orange)
  end
end