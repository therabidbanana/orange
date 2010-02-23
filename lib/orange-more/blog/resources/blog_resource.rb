module Orange
  class BlogPostResource < Orange::ModelResource
    use Orange::Blog
    call_me :blog
    def afterLoad
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Blog')      
    end
    
    def blog_view(packet, opts = {})
      resource_path = packet['route.resource_path']
      blog = Orange::Blog.first(:orange_site_id => packet['site'].id)
      if resource_path.blank?
        blog_url = orange[:sitemap, true].url_for(packet, :orange_site_id => blog.orange_site_id, :resource => :blog, :resource_id => blog.id, :resource_action => :blog_view)
        blog_url.gsub!(/\/$/, '')
        opts.merge!(:blog_url => blog_url)
        do_list_view(packet, :blog_list_view, opts)
      else
        parts = resource_path.split('/')
        post = blog.posts.year_and_month(parts[1].to_i, parts[2].to_i).slug(parts[3]) unless parts.size < 4
        if post
          do_view(packet, :blog_post_view, opts.merge({:model => post}))
        else
          "Not found"
        end
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
          :resource_action => :blog_view,
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