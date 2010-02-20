module Orange
  class Site < Carton
    id
    admin do
      title :name
      text :url
    end
  end
end