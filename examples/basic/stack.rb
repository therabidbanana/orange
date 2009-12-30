require 'rack/builder'
require 'rack/abstract_format'
require '../../lib/orange'

class Main < Orange::Application
  stack do
    auto_reload!
    use_exceptions
    stack Orange::Middleware::Globals
    prerouting :multi => true
    stack Orange::Middleware::Database
    stack Orange::Middleware::SiteLoad
    stack Orange::Middleware::Template
    
    openid_access_control
    restful_routing
    
    load Tester.new
    load Page_Resource.new, :pages

    run Main.new(orange)
  end
end