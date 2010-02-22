module Orange
  class BlogPostResource < Orange::ModelResource
    use Orange::Blog
    call_me :blog
    def afterLoad
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Blog')      
    end
    
    def blog_view(packet, opts = {})
      resource_path = packet['route.resource_path']
      if resource_path.blank?
        do_list_view(packet, :blog_list_view, opts)
      else
        do_view()
      end
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
      case mode
      when :blog_list_view then blog.posts.all(:order => :updated_at.desc, :limit => 5)
      else Orange::Blog.all
      end
    end
    
  end
end