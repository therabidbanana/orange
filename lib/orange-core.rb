libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.join('orange-core', 'magick.rb')
Dir.glob(File.join('orange-core', '*.rb')).each {|f| require f }
Dir.glob(File.join('orange-core', 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join('orange-core', 'middleware', '*.rb')).each {|f| require f }