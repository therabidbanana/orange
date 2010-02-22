module Orange
  class BlogResource < Orange::ModelResource
    use Orange::BlogPost
    call_me :blog_posts
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Blog')      
    end
    
    
    def publish(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          params = {}
          params[:published] = true
          m.update(params)
          params = m.attributes.merge(params)
          params.delete(:id)
          max = m.versions.max(:version) || 0
          m.versions.new(params.merge(:version => max + 1))
          m.save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, *opts)
      if packet.request.post?
        params = packet.request.params[@my_orange_name.to_s]
        params[:published] = false
        m = model_class.new(params)
        m.blog = Orange::Blog.first(:orange_site => packet['site'])
        # m.versions.new(params.merge(:version => 1))
        m.save
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def save(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          params = packet.request.params[@my_orange_name.to_s]
          params[:published] = false
          m.update(params)
          m.blog = Orange::Blog.first(:orange_site => packet['site'])
          m.save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def find_list(packet, mode, id =false)
      blog = Orange::Blog.first(:orange_site_id => packet['site'].id)
      unless blog
        blog = Orange::Blog.new
        blog.title = 'An Orange Hosted Blog'
        blog.orange_site = packet['site']
        blog.save
        orange[:sitemap, true].add_route_for(packet,
          :orange_site_id => packet['site'].id, 
          :resource => :blog, 
          :resource_id => blog.id,
          :action => 'blog_view',
          :slug => 'blog', 
          :link_text => 'Orange Blog'
        )
      end
      blog.posts
    end
    
    # Returns a single object found by the model class, given an id. 
    # If id isn't given, we return false.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Object] returns an object of type set by #use, if one found with same id
    def find_one(packet, mode, id = false)
      return false unless id
      m = model_class.get(id)
      if packet['route.resource_path',''] =~ /version\//
        parts = packet['route.resource_path'].split('/')
        version = parts[2]
        v = m.versions.first(:version => version)
        if v
          attrs = v.attributes
          [:version, :orange_page_id, :page_id, :id].each { |i| attrs.delete(i) }
          m.attributes = attrs
        end
      end
      m
    end
  end
end