module Orange
  class UserResource < Orange::ModelResource
    use Orange::User
    call_me :users
    def afterLoad
      orange[:admin].add_link("Settings", :resource => @my_orange_name, :text => 'Users')
    end
    
    def access_allowed?(packet, user)
      u = model_class.first(:open_id => user)
      return false unless u
      u.allowed?(packet)
    end
  end
end