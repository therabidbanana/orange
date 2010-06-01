require 'dm-timestamps'
class OrangeNews < Orange::Carton
  id
  front do
    title :title, :length => 255
    text :link, :length => 255
    fulltext :description
  end

  property :created_at, DateTime
  property :updated_at, DateTime
end