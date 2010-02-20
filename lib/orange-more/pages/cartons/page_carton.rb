require 'dm-timestamps'
require 'orange/cartons/site_carton'
module Orange
  class Page < Orange::SiteCarton
    id
    front do
      title :title
      fulltext :body
    end
    boolean :published, :default => false
    
    property :updated_at, DateTime
    has n, :versions, "Orange::PageVersion"
  end
end