require 'orange-core/carton'

module Orange
  class User < Orange::Carton
    id
    admin do
      title :name
      text :open_id
    end
    
    # Currently, all users allowed at all times.
    # Future support for roles to be built here.
    def allowed?(packet)
      true
    end
  end
end