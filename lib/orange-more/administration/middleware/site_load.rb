require 'orange-core/middleware/base'
module Orange::Middleware
  # This will load information about the site to into the orange env
  # - packet['site'] will be an instance of the site object
  # 
  class SiteLoad < Base    
    def packet_call(packet)
      url =  packet['route.site_url']
      site = OrangeSite.first(:url.like => url)
      if site
        packet['site'] = site
      elsif orange.options[:development_mode]
        s = OrangeSite.new({:url => packet['route.site_url'], 
                              :name => 'An Orange Site'})
        s.save
        packet['site'] = s
      else
        packet['site'] = OrangeSite.first
      end
      pass packet
    end
  end
  
end

