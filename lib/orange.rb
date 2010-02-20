libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.join(libdir, 'orange-core')
require File.join(libdir, 'orange-more')