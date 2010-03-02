module Orange
  class NewsResource < Orange::ModelResource
    use Orange::News
    call_me :news
    def afterLoad
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'News')
      
      orange.register(:stack_loaded) do
        orange[:radius, true].context.define_tag "latest_news" do |tag|
          orange[:news].latest(tag.locals.packet)
        end
      end   
    end
    
    def latest(packet)
      do_list_view(packet, :latest, {
        :list => model_class.all(:order => :created_at.desc, :limit => 3)
      })
    end
  end
end