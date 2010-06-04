class OrangeDonations < Orange::SiteCarton
  id
  admin do
    title :donor_name
    text :donor_company
    text :donor_email
    text :donation_amount
  end
  
  def self.with_tag(tag)
    all(:tags.like => "%#{tag}%")
  end

end