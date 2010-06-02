module Orange
  class BlogResource < Orange::ModelResource
    use OrangeBlogPost
    call_me :blog_posts
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Blog')      
    end
    
    
    def publish(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          m.publish!
          cloud_publish(packet, m)
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def cloud_publish(packet, post)
      orange[:cloud].microblog(packet, "New post on our blog: #{post.title} - http://#{packet['site'].url}#{orange[:blog].blog_url_for(packet)}/#{post.published_at.year}/#{post.published_at.month}/#{post.slug}") if post.published && !post.published_at.blank?
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def onNew(packet, params)
      params[:published] = false unless params.has_key?(:published) || params.has_key?("published")
      params[:author] = packet['user', false] ? packet['user'].name : "Author" unless params.has_key?(:author) || params.has_key?("author")
      
      blog = orange[:blog].blog_for_site(packet)
      post = blog.posts.new(params)
      post
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def onSave(packet, m, params = {})
      m.update(params)
      m.blog = orange[:blog].blog_for_site(packet) unless m.blog #ensure blog exists
      
      m.save
      cloud_publish(packet, m)
      m
    end
    
    def find_list(packet, mode, id =false)
      blog = orange[:blog].blog_for_site(packet)
      blog ? blog.posts.all(:order => [:updated_at.desc]) : [] 
    end
    
  end
end