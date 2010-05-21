class OrangeContactForms < Orange::Carton
  id
  admin do
    title :title
    text :to_address
  end
  
  def self.with_tag(tag)
    all(:tags.like => "%#{tag}%")
  end

end