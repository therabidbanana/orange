module Orange
  class CalendarResource < ModelResource
    use OrangeCalendar
    call_me :calendar
    def stack_init
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Calendars')
    end
    
    def afterNew(packet, obj, opts = {})
      obj.orange_site = packet['site'] unless obj.orange_site
    end
    
    
  end
end