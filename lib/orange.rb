libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

Dir.glob(File.join(File.dirname(__FILE__), 'orange', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'orange', 'middleware', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'orange', 'resource', '*.rb')).each {|f| require f }