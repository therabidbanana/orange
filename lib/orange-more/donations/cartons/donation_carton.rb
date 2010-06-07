class OrangeDonation < Orange::Carton
  id
  admin do
    title :donor_name, :length => 255
    text :donor_company, :length => 255
    text :donor_email, :length => 255
    text :donation_amount
  end
end