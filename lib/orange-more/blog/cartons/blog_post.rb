require 'dm-timestamps'
class OrangeBlogPost < Orange::Carton
  id
  front do
    title :title
    fulltext :body
  end
  admin do
    fulltext :summary
  end
  orange do
    boolean :published, :default => false
    text :slug
    text :author
  end
  
  property :created_at, DateTime
  property :published_at, DateTime
  property :updated_at, DateTime
  belongs_to :blog, "OrangeBlog"
  
  def title=(t)
    self.attribute_set('title', t)
    self.attribute_set('slug', t.downcase.gsub(/[']+/, "").gsub(/[^a-z0-9]+/, "_"))
  end
  
  def published=(val)
    self.published = val
    publish if val
  end
  
  def publish
    self.published_at = Time.now
    self.published = true
  end
  
  def publish!
    self.published_at = Time.now
    self.published = true
    self.save
  end
  
  def self.year_and_month(yr, mnth)
    all(:published_at.gte => DateTime.new(yr, mnth, 1), :published_at.lt => DateTime.new(yr, mnth + 1, 1))
  end
  
  def self.slug(slug)
    first(:slug => slug)
  end
  
  def self.published
    all(:published => true)
  end
  
  def self.draft
    all(:published => false)
  end
end