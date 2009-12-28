libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

Dir.glob(File.join(libdir, 'orange', '*.rb')).each {|f| require f }
Dir.glob(File.join(libdir, 'orange', 'cartons', '*.rb')).each {|f| require f }
Dir.glob(File.join(libdir, 'orange', 'resources', '*.rb')).each {|f| require f }
Dir.glob(File.join(libdir, 'orange', 'middleware', '*.rb')).each {|f| require f }