class OrangeCalendar < Orange::SiteCarton
  id
  admin do
    title :name
    boolean :main, :default => false, :display_name =>'Main Calendar?'
  end
  has n, :events, "OrangeEvent"
end