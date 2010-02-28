require 'dm-timestamps'
module Orange
  class News < Orange::Carton
    id
    front do
      title :title
      text :link
      fulltext :description
    end

    property :created_at, DateTime
    property :updated_at, DateTime
  end
end