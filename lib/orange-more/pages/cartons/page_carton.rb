require 'dm-timestamps'
require 'orange-more/administration/cartons/site_carton'

class OrangePage < Orange::SiteCarton
  id
  front do
    title :title, :length => 255
    fulltext :body
  end
  boolean :published, :default => false
  
  property :updated_at, DateTime
  has n, :versions, "OrangePageVersion"
end