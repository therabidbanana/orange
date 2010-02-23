require 'dm-timestamps'
module Orange
  class BlogPost < Orange::Carton
    id
    front do
      title :title
      fulltext :body
    end
    admin do
      fulltext :summary
    end
    orange do
      text :slug
      boolean :published, :default => false
    end
    
    property :created_at, DateTime
    property :updated_at, DateTime
    belongs_to :blog, "Orange::Blog"
    has n, :versions, "Orange::BlogPostVersion"
    
    def title=(t)
      self.attribute_set('title', t)
      self.attribute_set('slug', t.downcase.gsub(/[^a-z0-9-]+$/, ''))
    end
    
    def self.year_and_month(yr, mnth)
      all(:created_at.gte => DateTime.new(yr, mnth, 1), :created_at.lt => DateTime.new(yr, mnth + 1, 1))
    end
    
    def self.slug(slug)
      first(:slug => slug)
    end
  end
end