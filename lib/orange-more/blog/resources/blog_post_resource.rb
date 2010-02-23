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
          m.publish!
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
    
  end
end