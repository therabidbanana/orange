module Orange
  class NewsResource < Orange::ModelResource
    use Orange::News
    call_me :news
    def afterLoad
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'News')      
    end
  end
end