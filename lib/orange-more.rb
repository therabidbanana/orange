libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.join(libdir, 'orange-core', 'magick.rb')
Dir.glob(File.join(libdir, 'orange-core', '*.rb')).each {|f| require f }
Dir.glob(File.join(libdir, 'orange-core', 'cartons', '*.rb')).each {|f| require f }
require File.join(libdir, 'orange-core', 'resources', 'model_resource.rb')
Dir.glob(File.join(libdir, 'orange-core', 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(libdir, 'orange-core', 'middleware', '*.rb')).each {|f| require f }