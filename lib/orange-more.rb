libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.join(libdir, 'orange-core')

require File.join(libdir, 'orange-more', 'administration')
require File.join(libdir, 'orange-more', 'assets')
require File.join(libdir, 'orange-more', 'pages')
require File.join(libdir, 'orange-more', 'sitemap')
require File.join(libdir, 'orange-more', 'slices')
require File.join(libdir, 'orange-more', 'blog')