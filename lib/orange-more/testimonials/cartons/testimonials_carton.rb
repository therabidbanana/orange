module Orange
  class Testimonial < Orange::Carton
    id
    admin do
      title :name
      text :position
      text :company
      text :tags
      fulltext :blurb
    end
    
    def self.with_tag(tag)
      all(:tags.like => "%#{tag}%")
    end
    
  end
end