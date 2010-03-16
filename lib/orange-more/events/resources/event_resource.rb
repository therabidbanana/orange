module Orange
  class EventResource < ModelResource
    use OrangeEvent
    call_me :events
    
    def find_extras(packet, mode, opts = {})
      {:calendars => OrangeCalendar.all}
    end
  end
end