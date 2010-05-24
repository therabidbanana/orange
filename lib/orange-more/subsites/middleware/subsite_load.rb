require 'orange-core/middleware/base'
module Orange::Middleware
  # This will load information about the site to into the orange env
  # - packet['site'] will be an instance of the site object
  # 
  class SubsiteLoad < Base    
    def packet_call(packet)
      if packet['site']
        site = packet['site']
        path = packet['route.path'] || packet.request.path_info
        
        # Find the subsite in the sitemap table
        extras, matched = orange[:sitemap].find_route_info(packet, path)
        
        # If matched, update the loaded site and trim the path down a bit
        if !matched.resource.blank? && matched.resource.to_sym == :subsites
          if(m = site.subsites.first(:id => matched.resource_id))
            packet['route.main_site_route'] = matched
            packet['route.path'] = extras
            packet['subsite'] = m
          end
        end
      end
      pass packet
    end
  end
  
end

