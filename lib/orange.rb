libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

$ORANGE_PATH = File.join(File.dirname(__FILE__), 'orange')
$ORANGE_ASSETS = File.join($ORANGE_PATH, 'assets')
$ORANGE_VIEWS = File.join($ORANGE_PATH, 'views')

Dir.glob(File.join(File.dirname(__FILE__), 'orange', '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'orange', 'middleware', '*.rb')).each {|f| require f }