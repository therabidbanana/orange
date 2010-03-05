module Orange
  class UserResource < Orange::ModelResource
    use OrangeUser
    call_me :users
    def afterLoad
      orange[:admin].add_link("Settings", :resource => @my_orange_name, :text => 'Users')
    end
    
    def access_allowed?(packet, user)
      u = model_class.first(:open_id => user)
      return false unless u
      u.allowed?(packet)
    end
    
    def user_for(packet)
      model_class.first(:open_id => packet['user.id'])
    end
    
    def new(packet, *opts)
      if packet.request.post?
        params = packet.request.params[@my_orange_name.to_s]
        sites = params.delete 'sites'
        m = model_class.new(params)
        m.save
        sites.each{|k,v| s = OrangeSite.first(:id => k); m.orange_sites << s if s} if sites
        m.save
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def save(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          params = packet.request.params[@my_orange_name.to_s]
          sites = params.delete 'sites'
          m.update(params)
          m.orange_sites.destroy
          sites.each{|k,v| s = OrangeSite.first(:id => k); m.orange_sites << s if s} if sites
          m.save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def find_extras(packet, mode)
      {:sites => OrangeSite.all}
    end
  end
end