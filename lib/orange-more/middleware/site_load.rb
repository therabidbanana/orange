require 'orange/middleware/base'
module Orange::Middleware
  # This will load information about the site to into the orange env
  # - packet['site'] will be an instance of the site object
  # 
  class SiteLoad < Base
    def init(*args)
      orange.load Orange::SiteResource.new, :orange_sites
    end
    
    def packet_call(packet)
      url =  packet['route.site_url']
      site = Orange::Site.first(:url.like => url)
      if site
        packet['site'] = site
      else
        s = Orange::Site.new({:url => packet['route.site_url'], 
                              :name => 'An Orange Site'})
        s.save
        packet['site'] = s
      end
      pass packet
    end
  end
  
end

module Orange
  class Site < Carton
    id
    admin do
      title :name
      text :url
    end
  end
  
  class SiteResource < ModelResource
    use Orange::Site
    def afterLoad
      orange[:admin, true].add_link('Settings', :resource => @my_orange_name, 
                                                :text => 'Site')
    end
  end
end