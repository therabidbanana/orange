require 'dm-timestamps'

module Orange
  class Page < Orange::Carton
    id
    front do
      title :title
      fulltext :body
    end
    property :updated_at, DateTime
    has n, :versions, "Orange::PageVersion"
  end
end