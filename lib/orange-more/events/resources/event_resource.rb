require 'eventbright'
require 'json'
module Orange
  class EventResource < ModelResource
    # For integration with Eventbrite. Application key needs user
    # key for full access.
    ORANGE_EVENTBRITE_KEY = "ODQ5MDMzZWQwOWRl"
    
    use OrangeEvent
    call_me :events
    
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Events')
      EventBright.setup(ORANGE_EVENTBRITE_KEY)
      options[:eventbrite_key] = orange.options['eventbrite_key'] || false
    end
    
    def eventbrite_user
      return false unless options[:eventbrite_key]
      begin
        @eventbrite_user = EventBright::User.new(options[:eventbrite_key]) 
      rescue # If EventBright gem throws error, we're probably having issues connecting
        false
      end
    end
    
    def find_extras(packet, mode, opts = {})
      extras = {:calendars => OrangeCalendar.all}
      case mode
      when :create, :edit
        ev = eventbrite_venues
        ee = eventbrite_events
        ev_json = {} if ev
        ev.each{|v| ev_json[v.id] = v.attributes.merge(:id => v.id)} if ev
        ee_json = {} if ee
        ee.each{|v| ee_json[v.id] = v.attributes.merge(:id => v.id)} if ee
        extras.merge!(:eventbrite_venues => ev, :venues_json => ev_json.to_json, 
                      :eventbrite_events => ee, :events_json => ee_json.to_json
                      ) if options[:eventbrite_key]
      
      end
      extras
    end
    
    def beforeNew(packet, params = {})
      eventbrite_synchronize(packet, params)
      true
    end
    
    def beforeSave(packet, model, params = {})
      eventbrite_synchronize(packet, params)
      true
    end
    
    def eventbrite_synchronize(packet, params = {})
      venue_id = params.delete('orange_venue_id')
      if params['link_to_eventbrite'] != "0" 
        if venue_id == "new"
          v = EventBright::Venue.new(eventbrite_user)
          v.organizer_id = eventbrite_user.organizers.first.id
        else
          v = eventbrite_user.venues.select{|v| v.id == venue_id.to_i }.first
        end
        update_venue(v, params)
        if params['eventbrite_id'] == "new"
          e = EventBright::Event.new(eventbrite_user)
          e.organizer = eventbrite_user.organizers.first
        else
          e = eventbrite_user.events.select{|e| e.id == params['eventbrite_id'].to_i }.first
        end
        params['eventbrite_id'] = update_event(e, params, v)
      else
        params['eventbrite_id'] = nil
      end
      params
    end
    
    def update_event(event, params, venue)
      event.venue = venue
      event.title = params["name"]
      event.description = params["description"]
      event.start_date = params["starts_date"] + " " + params["starts_time"]
      event.end_date = params["ends_date"] + " " + params["ends_time"]
      if(event.start_date > event.end_date)
        raise "An event can't end before it starts."
      else
        event.status = "live"
        event.save
      end
      return event.id
    end
    
    def update_venue(venue, params)
      venue.name = params["location_name"]
      venue.address = params["location_address"]
      venue.address_2 = params["location_address2"]
      venue.city = params["location_city"]
      venue.region = params["location_state"]
      venue.postal_code = params["location_zip"]
      venue.country_code = "US"
      venue.save
    end
    
    
    def post_to_eventbrite
      
    end
    
    def eventbrite_venues
      list = []
      begin
        list = eventbrite_user.venues
      rescue
        return false
      end
      list
    end
    
    def eventbrite_events
      list = []
      begin
        list = eventbrite_user.events
      rescue
        return false
      end
      list
    end
  end
end