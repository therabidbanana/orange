#\-s thin -p 4321
require 'main'
require '../../lib/orange'
require 'rubygems'
require 'rack'

# app = Orange::Stack.new do
#   stack Orange::Middleware::Static
#   stack Orange::Middleware::RouteSite, :multi => false
#   stack Orange::Middleware::RouteContext
#   
#   use Rack::AbstractFormat
#   run Main.new
# end

run Main.app
# From commandline - 
# rackup [config.ru] [-s thin -p 4321]