require 'main'
require 'lib/orange'
require 'rack/abstract_format'

use Rack::CommonLogger
use Orange::Middleware::ShowExceptions
use Rack::Reloader
use Rack::MethodOverride
use Rack::Session::Cookie, :secret => 'orange_secret'
use Rack::Static, :urls => ["/assets", "/favicon.ico"]

use Rack::AbstractFormat
use Orange::Middleware::RouteContext

# Always use right before final app.
use Orange::Middleware::Reloader 
run Main.new do
  no_database true
end

# From commandline - 
# rackup config.rb -s mongrel -p 4321