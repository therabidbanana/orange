module Orange
  class Testimonial < Orange::Carton
    id
    admin do
      title :name
      fulltext :blurb
    end
  end
end