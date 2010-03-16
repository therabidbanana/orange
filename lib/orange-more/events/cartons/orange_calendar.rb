class OrangeCalendar < Orange::SiteCarton
  id
  admin do
    title :name
  end
  has n, :events, "OrangeEvent"
end