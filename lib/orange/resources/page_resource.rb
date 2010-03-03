module Orange
  module Pulp::PageHelpers
    def fuzzy_time(from_time)
      to_time = Time.new
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round
        case distance_in_minutes
          when 0..1
            return distance_in_minutes == 0 ? "Less than 1 minute ago" : "About 1 minute ago"
          when 2..44           then "#{distance_in_minutes} minutes ago"
          when 45..89          then "An hour ago"
          when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
          when 1440..2879      then "Yesterday"
          when 2880..43199     then "#{(distance_in_minutes / 1440).round} days ago"
          when 43200..86399    then "1 Month ago"
          when 86400..525599   then "#{(distance_in_minutes / 43200).round} months ago"
          when 525600..1051199 then "1 year ago"
          else                      "Over #{(distance_in_minutes / 525600).round} years ago"
        end
    end
  end
  class PageResource < Orange::ModelResource
    use Orange::Page
    call_me :pages
    def afterLoad
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Pages')
      options[:sitemappable] = true
      orange.add_pulp(Orange::Pulp::PageHelpers)
    end
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, *opts)
      if packet.request.post?
        m = model_class.new(packet.request.params[@my_orange_name.to_s])
        m.versions.new(packet.request.params[@my_orange_name.to_s].merge(:version => 1))
        m.save
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def save(packet, *opts)
      if packet.request.post?
        m = model_class.get(packet['route.resource_id'])
        if m
          m.update(packet.request.params[@my_orange_name.to_s])
          max = m.versions.max(:version)
          m.versions.new(packet.request.params[@my_orange_name.to_s].merge(:version => max + 1))
          m.save
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    
    
    # Returns a single object found by the model class, given an id. 
    # If id isn't given, we return false.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Object] returns an object of type set by #use, if one found with same id
    def find_one(packet, mode, id = false)
      return false unless id
      m = model_class.get(id)
      if packet['route.resource_path',''] =~ /version\//
        parts = packet['route.resource_path'].split('/')
        version = parts[2]
        v = m.versions.first(:version => version)
        if v
          attrs = v.attributes
          [:version, :orange_page_id, :page_id, :id].each { |i| attrs.delete(i) }
          m.attributes = attrs
        end
      end
      m
    end
  end
end