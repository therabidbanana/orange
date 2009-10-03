require 'main'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Reloader
use Rack::Session::Cookie, :secret => 'orange_secret'
use Rack::Static, :urls => ["/assets"]
run Main.new

# From commandline - 
# rackup config.rb -s mongrel -p 4321