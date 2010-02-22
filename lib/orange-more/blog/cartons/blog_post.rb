require 'dm-timestamps'
module Orange
  class BlogPost < Orange::Carton
    id
    front do
      title :title
      fulltext :summary
      fulltext :body
    end
    boolean :published, :default => false
    
    property :updated_at, DateTime
    belongs_to :blog, "Orange::Blog"
    has n, :versions, "Orange::BlogPostVersion"
  end
end