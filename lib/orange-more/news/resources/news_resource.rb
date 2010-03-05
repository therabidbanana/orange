module Orange
  class NewsResource < Orange::ModelResource
    use Orange::News
    call_me :news
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'News')
      
      orange.register(:stack_loaded) do
        orange[:radius, true].context.define_tag "latest_news" do |tag|
          orange[:news].latest(tag.locals.packet)
        end
      end
    end
    
    def new(packet, opts = {})
      news = Orange::News.first()
      unless Orange::Route.first(:resource => 'news')
        orange[:sitemap, true].add_route_for(packet,
          :orange_site_id => packet['site'].id, 
          :resource => :news, 
          :resource_action => :archive,
          :slug => 'archive', 
          :link_text => 'Orange News Archive'
        )
      end
      
      super(packet, opts)
    end
    
    def sitemap_row(packet, opts = {})
      do_view(packet, :sitemap_row, opts)
    end
    
    def news_view(packet, opts = {})
      resource_path = packet['route.resource_path']
      if resource_path.blank?
        archive_view(packet, opts)
      elsif resource_path =~ /^\/page/
        archive(packet, opts)
      else
        archive_view(packet, opts)
      end
    end
    
    def latest(packet)
      do_list_view(packet, :latest, {
        :list => model_class.all(:order => :created_at.desc, :limit => 3)
      })
    end
    
    def archive(packet, opts = {})
      opts.merge!(packet.extract_opts)
      opts.merge!( :archive_url => archive_url(packet))
      opts[:page] = opts[:page].blank? ? 1 : opts[:page].to_i
      page = opts[:page].blank? ? 0 : opts[:page] - 1 
      opts[:list] = model_class.all(:order => :created_at.desc, 
          :limit => 5, 
          :offset => (5*page)
      )
      opts[:pages] = (model_class.count / 5) + 1
      do_list_view(packet, :archive, opts)
    end
    
    def archive_view(packet, opts = {})
      archive(packet, opts.merge!({:page => 1}))
    end
    
    def archive_url(packet)
      url = orange[:sitemap, true].url_for(packet, :resource => :news, :resource_action => :archive)
      url.gsub!(/\/$/, '')
    end
  end
end