libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'orange-core'

require File.join('orange-more', 'template')
require File.join('orange-more', 'administration')
require File.join('orange-more', 'assets')
require File.join('orange-more', 'pages')
require File.join('orange-more', 'sitemap')
require File.join('orange-more', 'slices')