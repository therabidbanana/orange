module Orange
  class Asset < Orange::Carton
    id
    admin do
      title :name
      text :caption
    end
    orange do
      string :path, :length => 255
      string :mime_type
      string :secondary_path, :length => 255, :required => false
      string :secondary_mime_type
    end
    
    def file_path
      File.join('', 'assets', 'uploaded', path)
    end
    
    def to_asset_tag
      "<img src=\"#{file_path}\" border=\"0\"/>"
    end
  end
end