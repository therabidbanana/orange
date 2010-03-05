module Orange
  class BlogResource < Orange::ModelResource
    use OrangeBlogPost
    call_me :blog_posts
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Blog')      
    end
    
    
    def publish(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          # orange[:cloud, true].microblog(packet, "I just posted a test blog post.")
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
        params[:author] = packet['user', false] ? packet['user'].name : "Author"
        
        blog = OrangeBlog.first(:orange_site => (packet['subsite'].blank? ? packet['site'] : packet['subsite']))
        blog.posts.new(params)
        blog.save
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
          m.blog = OrangeBlog.first(:orange_site => (packet['subsite'].blank? ? packet['site'] : packet['subsite']))
          m.save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def find_list(packet, mode, id =false)
      blog = orange[:blog].blog_for_site(packet)
      blog.posts
    end
    
  end
end