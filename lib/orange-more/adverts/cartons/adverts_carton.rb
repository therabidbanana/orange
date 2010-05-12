class OrangeAdvert < Orange::Carton
  id
  admin do
    title :title
    text :asset_id
    text :link
    text :alt_text
  end
  
  def self.with_tag(tag)
    all(:tags.like => "%#{tag}%")
  end

end