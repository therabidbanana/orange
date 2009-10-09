#\-s thin -p 4321
require 'main'
require 'lib/orange'
require 'rubygems'
require 'rack'
require 'rack/builder'
require 'rack/abstract_format'

use Rack::CommonLogger
use Orange::Middleware::ShowExceptions
use Rack::Reloader
use Rack::MethodOverride
use Rack::Session::Cookie, :secret => 'orange_secret'

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