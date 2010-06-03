require 'md5'

class OrangeMember < Orange::Carton
  id
  front do
    text :first_name
    text :last_name
    text :email
    text :title
    text :organization
  end  
  text :hashed_password
  text :salt
  text :reset_token
  property :reset_on, DateTime
  
  def password=(val)
    attribute_set(:hashed_password, Digest::MD5.hexdigest("#{salt}orange-is-awesome#{val}"))
  end
  
  def salt
    my_salt = attribute_get(:salt)
    unless(my_salt)
      my_salt = Digest::MD5.hexdigest(Time.now.iso8601)
      attribute_set(:salt, my_salt)
    end
    my_salt
  end
  
  def reset!
    token = Digest::MD5.hexdigest(Time.now.iso8601)
    # Invalidate password
    attribute_set(:hashed_password, Digest::MD5.hexdigest("#{salt}#{token}"))
    attribute_set(:reset_on, DateTime)
    attribute_set(:reset_token, token)
  end
  
end