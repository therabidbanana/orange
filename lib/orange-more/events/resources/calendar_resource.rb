module Orange
  class CalendarResource < ModelResource
    use OrangeCalendar
    call_me :calendar
    
    def afterNew(packet, obj, opts = {})
      obj.orange_site = packet['site'] unless obj.orange_site
    end
    
    
  end
end