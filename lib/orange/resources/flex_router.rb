require 'orange/core'
require 'orange/resources/model_resource'
require 'orange/cartons/site_carton'
require 'dm-is-nested_set'
module Orange
  class Route < SiteCarton
    id
    text :slug
  
    is :nested_set, :scope => [:orange_site_id]
  end
  class RouteResource < ModelResource
    use Orange::Route
    
  end
end