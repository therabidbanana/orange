require 'orange/core'
require 'dm-is-nested_set'
module Orange
  class FlexRouter
    
  end
  
  class Route < SiteCarton
    id
    
    is :nested_set, :scope => [:orange_site_id]
  end
end