require 'main'

require 'rack/abstract_format'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Reloader
use Rack::Session::Cookie, :secret => 'orange_secret'
use Rack::Static, :urls => ["/assets", "/favicon.ico"]

use Rack::AbstractFormat

run Main.new do 
  no_database true
end

# From commandline - 
# rackup config.rb -s mongrel -p 4321