require 'orange-more/administration/cartons/site_carton'
class OrangeBlog < Orange::SiteCarton
  id
  front do
    title :title
  end
  has n, :posts, "OrangeBlogPost"
end
