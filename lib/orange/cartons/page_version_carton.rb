require 'dm-timestamps'
module Orange
  class PageVersion < Orange::Carton
    id
    title :title
    fulltext :body
    property :updated_at, DateTime
    property :version, Integer, :default => 0
    belongs_to :orange_page, "Orange::Page"
  end
end