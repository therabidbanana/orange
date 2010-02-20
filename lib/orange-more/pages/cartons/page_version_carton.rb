require 'dm-timestamps'
require 'orange-more/administration/cartons/site_carton'
module Orange
  class PageVersion < Orange::SiteCarton
    id
    title :title
    fulltext :body
    property :updated_at, DateTime
    boolean :published
    property :version, Integer, :default => 0
    belongs_to :orange_page, "Orange::Page"
  end
end