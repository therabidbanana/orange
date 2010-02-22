require 'orange-more/administration/cartons/site_carton'
module Orange
  class Blog < Orange::SiteCarton
    id
    front do
      title :title
    end
    has n, :posts, "Orange::BlogPost"
  end
end