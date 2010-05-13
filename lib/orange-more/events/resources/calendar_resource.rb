module Orange
  class CalendarResource < ModelResource
    use OrangeCalendar
    call_me :calendar
    def stack_init
      orange[:admin, true].add_link("Settings", :resource => @my_orange_name, :text => 'Calendars')
      orange[:radius].define_tag "calendar" do |tag|
     	  template = tag.attr["template"] || false
     	  if tag.attr["name"]
     	    calendars = tag.attr["name"].split.map{|x| model_class.first(:name => x)}
        else
          calendars = model_class.all
        end
        events = OrangeEvent.all(:calendar => calendars, :order => [:starts.asc], :limit => 10)
        orange[:calendar].calendar(tag.locals.packet, {:list => events, :template => template})
      end
    end
    
    def calendar(packet, opts = {})
      template = (opts[:template] || "calendar").to_sym
      do_list_view(packet, template, opts)
    end
    
    def afterNew(packet, obj, opts = {})
      obj.orange_site = packet['site'] unless obj.orange_site
    end
    
    
  end
end