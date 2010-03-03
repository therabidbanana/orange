module Orange
  class SiteResource < ModelResource
    use OrangeSite
    call_me :orange_sites
    def afterLoad
      orange[:admin].add_link('Settings', :resource => @my_orange_name, 
                                                :text => 'Site')
    end
  end
end