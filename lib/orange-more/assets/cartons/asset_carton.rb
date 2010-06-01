class OrangeAsset < Orange::Carton
  id
  admin do
    title :name, :length => 255
    text :caption, :length => 255
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
  
  def to_s
    <<-DOC
    {"id": #{self.id}, "html": "#{self.to_asset_tag}"}
    DOC
  end
  
  def to_asset_tag(alt = "")
    "<img src='#{file_path}' border='0' alt='#{alt}' />"
  end
end
