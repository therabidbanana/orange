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
    use OrangePage
    call_me :pages
    def init
      options[:sitemappable] = true
      orange.add_pulp(Orange::Pulp::PageHelpers)
    end
    
    def stack_init
      orange[:admin, true].add_link("Content", :resource => @my_orange_name, :text => 'Pages')
    end
    
    def publish(packet, opts = {})
      no_reroute = opts[:no_reroute]
      if packet.request.post? || !opts.blank?
        my_id = opts[:resource_id] || packet['route.resource_id']
        m = opts[:model] || model_class.get(my_id)
        if m
          params = {}
          params[:published] = true
          m.update(params)
          
          params = m.attributes.merge(params)
          params.delete(:id)
          max = m.versions.max(:version) || 0
          m.versions.new(params.merge(:version => max + 1))
          m.save
          
          r = orange[:sitemap, true].routes_for(packet, :resource_id => m.id, :resource => @my_orange_name, :orange_site_id => m.orange_site.id)
          # Add route if none.
          if (r.blank? && orange.loaded?(:sitemap))
            
            route_hash = {
              :orange_site_id => m.orange_site.id, 
              :resource => @my_orange_name, 
              :resource_id => m.id,
              :slug => orange[:sitemap].slug_for(m, params), 
              :show_in_nav => false,
              :link_text => "{title}"
            }
            parents = orange[:sitemap].routes_for(packet, :resource => '', :resource_id => '', :slug => "pages", :orange_site_id => m.orange_site.id)
            route_hash[:parent] = parents.first unless parents.blank?
            orange[:sitemap].add_route_for(packet, route_hash)
          end
        end
      end
      packet.reroute(@my_orange_name, :orange) unless (packet.request.xhr? || no_reroute)
    end

    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def onNew(packet, params = {})
      params[:published] = false
      m = model_class.new(params)
      m.orange_site = (packet['subsite', false] ? packet['subsite'] : packet['site']) unless m.orange_site
      # m.versions.new(params.merge(:version => 1))
      m
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def onSave(packet, m, params = {})
      r = orange[:sitemap, true].routes_for(packet, :resource_id => m.id, :resource => @my_orange_name, :orange_site_id => m.orange_site.id)
      # Add route if none.
      if (r.blank? && orange.loaded?(:sitemap))
        route_hash = {
          :orange_site_id => m.orange_site.id, 
          :resource => @my_orange_name, 
          :resource_id => m.id,
          :slug => orange[:sitemap].slug_for(m, params), 
          :show_in_nav => false,
          :link_text => "{title}"
        }
        parents = orange[:sitemap].routes_for(packet, :resource => '', :resource_id => '', :slug => "pages", :orange_site_id => m.orange_site.id)
        route_hash[:parent] = parents.first unless parents.blank?
        orange[:sitemap].add_route_for(packet, route_hash)
      end
      if (params["published"] == "1")
        params["published"] = true
        m.orange_site = (packet['subsite', false] ? packet['subsite'] : packet['site']) unless m.orange_site
        
        m.update(params)
        orange[:pages].publish(packet, :no_reroute => true, :model => m)
      else
        params["published"] = false
        m.orange_site = (packet['subsite', false] ? packet['subsite'] : packet['site']) unless m.orange_site
        m.update(params)
      end
    end
    
    def find_list(packet, mode)
      model_class.all(:orange_site => packet['site']) || []
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
      end # end if version
      if mode == :show
        case packet['route.context']  
        when :live
          # Automatically set title, if possible
          unless orange[:page_parts].part(packet)[:title] != '' 
            orange[:page_parts].part(packet)[:title] = m.title + " - " + packet['site'].name
          end
          m = m.versions.last(:published => '1')
          raise Orange::NotFoundException unless m
        when :preview
          # Automatically set title, if possible
          unless orange[:page_parts].part(packet)[:title] != '' 
            orange[:page_parts].part(packet)[:title] = m.title + " - " + packet['site'].name
          end
          m
        end
      end # end if show
      m
    end
    
    def find_extras(packet, mode, opts = {})
      case mode
      when :edit
        return {:routes => orange[:sitemap, true].routes_for(packet)}
      else {}
      end
    end
    
    def routes(packet, opts = {})
      model = opts if opts.is_a? model_class
      model ||= opts[:model] || model_class.get(opts[:resource_id])
      orange[:sitemap].routes_for(packet, {:resource => :pages, :resource_id => model.id})
    end
    
    def sitemap_row(packet, opts = {})
      do_view(packet, :sitemap_row, opts)
    end
    
    def route_for(packet, id, opts = {})
      return orange[:sitemap].url_for(packet, {:resource => 'pages', :resource_id => id})
    end
  end
end