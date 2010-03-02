module Orange
  class Site < Carton
    property :type, Discriminator
    has n, :subsites, 'Orange::Subsite'
  end
end
module Orange
  class Subsite < Site
    belongs_to :site, 'Orange::Site'
    
  end
end
