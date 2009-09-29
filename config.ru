require 'rubygems'
require 'lib/orange'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Reloader
use Rack::Static, :urls => ["/assets"]
run Orange::Core.new

# From commandline - 
# rackup config.rb -s mongrel -p 4321