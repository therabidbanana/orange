libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

$ORANGE_PATH = File.join(File.dirname(__FILE__), 'orange')
$ORANGE_ASSETS = File.join($ORANGE_PATH, 'assets')
$ORANGE_VIEWS = File.join($ORANGE_PATH, 'views')

require 'orange/core'
