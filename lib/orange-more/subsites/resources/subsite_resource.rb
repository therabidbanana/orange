module Orange
  class SubsiteResource < Orange::ModelResource
    use OrangeSubsite
    call_me :subsites
    def stack_init
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Subsites')
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, *opts)
      if packet.request.post?
        m = packet['site'].subsites.new(packet.request.params[@my_orange_name.to_s])
        m.save
        orange[:sitemap].add_route_for(packet,
          :orange_site_id => packet['site'].id, 
          :resource => :subsites, 
          :resource_id => m.id,
          :slug => 'subsite', 
          :link_text => 'Orange Subsite'
        )
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def url_for(packet)
      orange[:sitemap].url_for(packet, {:resource => 'subsites', :resource_id => packet['subsite'].id})
    end
    
    
  end
  
  class Mapper < Resource
    def route_to(packet, resource, *args)
      opts = args.extract_options!
      packet = DefaultHash.new unless packet 
      context = opts[:context] || packet['route.context', nil]
      site = packet['route.faked_site'] ? packet['route.site_url', nil] : nil
      args.unshift(resource)
      args.unshift(orange[:subsites].url_for(packet).gsub(/^\//, '').gsub(/\/$/, '')) if(packet['subsite'])
      args.unshift(context)
      args.unshift(site)
      '/'+args.compact.join('/')
    end
  end
end