module Orange
  class Asset < Orange::Carton
    id
    admin do
      title :name
      text :caption
    end
    orange do
      string :mime_type
      string :secondary_mime_type
      string :path, :length => 255
      string :secondary_path, :length => 255, :required => false
    end
    
    def file_path
      File.join('', 'assets', 'uploaded', path)
    end
    
    def to_asset_tag
      "<img src=\"#{file_path}\" />"
    end
  end
end