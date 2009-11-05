require 'rack/builder'
require 'rack/abstract_format'

Main.stack do
  auto_reload!
  use_exceptions
  stack Orange::Middleware::Globals
  prerouting :multi => false
  
  stack Orange::Middleware::Template
  restful_routing
  stack Orange::Middleware::Database
  load Tester.new
  load Page_Resource.new, :pages
  
  run Main.new(orange)
end