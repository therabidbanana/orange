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
use Orange::Middleware::Static

use Rack::AbstractFormat
app = Orange::Stack.new do
  use Orange::Middleware::RouteSite, :multi => false
  use Orange::Middleware::RouteContext
  
  run Main.new
end

run app
# From commandline - 
# rackup config.rb -s mongrel -p 4321