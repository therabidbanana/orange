module Orange
  class SiteResource < ModelResource
    use Orange::Site
    def afterLoad
      orange[:admin, true].add_link('Settings', :resource => @my_orange_name, 
                                                :text => 'Site')
    end
  end
end