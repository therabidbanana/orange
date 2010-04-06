require 'rest_client'

module Orange
  class EventResource < ModelResource
    # For integration with Eventbrite. Application key needs user
    # key for full access.
    ORANGE_EVENTBRITE_KEY = "ODQ5MDMzZWQwOWRl"
    
    use OrangeEvent
    call_me :events
    
    def stack_init
      options[:eventbrite_key] = orange.options['eventbrite_key'] || false
    end
    
    def find_extras(packet, mode, opts = {})
      extras = {:calendars => OrangeCalendar.all}
      case mode
      when :create
        ev = eventbrite_venues
        extras.merge!(:eventbrite_venues => eventbrite_venues) if options[:eventbrite_key]
      end
      extras
    end
    
    def post_to_eventbrite
      
    end
    
    def eventbrite_venues
      list = []
      begin
        response = RestClient.get("https://www.eventbrite.com/xml/user_list_venues?app_key=#{ORANGE_EVENTBRITE_KEY}&user_key=#{options[:eventbrite_key]}")
        xml = orange[:parser].xml(response.body)
        list = xml["venues"]["venue"].select{|x| !x['country'].blank? }
      rescue
        return false
      end
      list
    end
  end
end