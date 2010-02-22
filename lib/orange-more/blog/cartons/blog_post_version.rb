require 'dm-timestamps'
module Orange
  class BlogPostVersion < Orange::Carton
    id
    title :title
    fulltext :summary
    fulltext :body
    property :updated_at, DateTime
    boolean :published
    property :version, Integer, :default => 0
    belongs_to :post, "Orange::BlogPost"
  end
end