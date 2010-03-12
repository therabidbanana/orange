class OrangeSite < Orange::Carton
  property :type, Discriminator
  has n, :subsites, 'OrangeSubsite'
end

class OrangeSubsite < OrangeSite
  belongs_to :orange_site, :required => false
end
