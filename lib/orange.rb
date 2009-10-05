libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

$ORANGE_PATH = File.dirname(__FILE__) + '/orange/'
$ORANGE_VIEW = $ORANGE_PATH + '/views/'

require 'orange/core'
