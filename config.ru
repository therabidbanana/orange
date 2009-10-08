require 'main'
require 'lib/orange'
require 'rack/abstract_format'

use Rack::CommonLogger
use Orange::Middleware::ShowExceptions
use Rack::Reloader
use Rack::MethodOverride
use Rack::Session::Cookie, :secret => 'orange_secret'
use Orange::Middleware::Static

use Rack::AbstractFormat
use Orange::Middleware::RouteSite, :multi => false
use Orange::Middleware::RouteContext

# Always use reloader right before final app - useless otherwise
use Orange::Middleware::Reloader 
run Main.new do
  no_database true
end

# From commandline - 
# rackup config.rb -s mongrel -p 4321