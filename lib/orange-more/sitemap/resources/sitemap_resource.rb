require 'orange-core/core'
require 'orange-core/resources/model_resource'
module Orange
  
  class SitemapResource < ModelResource
    use OrangeRoute
    call_me :sitemap
    def afterLoad
      orange[:admin, true].add_link('Content', :resource => @my_orange_name, :text => 'Sitemap')
      
    end
    def route_actions(packet, opts = {})
      do_view(packet, :route_actions, opts)
    end
    
    def route(packet)
      resource = packet['route.resource']
      raise 'resource not found' unless orange.loaded? resource
      unless (packet['route.resource_action'])
        packet['route.resource_action'] = (packet['route.resource_id'] ? :show : :index)
      end
      
      packet[:content] = (orange[resource].view packet)
    end
    
    # Path should be an array of path parts
    def find_route_info(packet, path)
      parts = path.split('/')
      pad = parts.shift
      matched = home(packet, :subsite => true)
      extras = ''
      while (!parts.empty?)
        next_part = parts.shift
        matches = matched.children.first(:slug => next_part)
        if(matches) 
          matched = matches
        else
          extras = parts.unshift(next_part).unshift(pad).join('/')
          parts = []
        end
      end
      [extras, matched]
    end
    
    def route?(packet, path)
      extras, matched = find_route_info(packet, path)
      return false if(extras.length > 0 && !matched.accept_args)
      packet['route.path'] = path
      packet['route.route'] = matched
      packet['route.resource'] = matched.resource.to_sym unless matched.resource.blank?
      packet['route.resource_id'] = matched.resource_id.to_i unless matched.resource_id.blank?
      packet['route.resource_action'] = matched.resource_action.to_sym unless  matched.resource_action.blank?
      # allow "resource_paths" - extra arguments added as path parts
      packet['route.resource_path'] = extras
      return true
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def onNew(packet, params = {})
        params.with_defaults!(:orange_site_id => (packet['subsite'].blank? ? packet['site'].id : packet['subsite'].id))
        model_class.new(params)
    end
    
    def afterNew(packet, obj, params = {})
      obj.move(:into => home(packet))
    end
    
    def move(packet, obj, opts = {})
      no_reroute = opts.delete(:no_reroute)
      if packet.request.post? || !opts.blank?
        dir = opts[:direction]
        obj ||= find_one(packet, :move, (opts[:id] || packet['route.resource_id']))
        obj.move(dir) if obj
      end
      packet.reroute(@my_orange_name, :orange) unless (packet.request.xhr? || no_reroute)
    end
    
    def higher(packet, opts = {})
      move(packet, false, :direction => :higher)
    end
    
    def lower(packet, opts = {})
      move(packet, false, :direction => :lower)
    end
    
    def outdent(packet, opts = {})
      move(packet, false, :direction => :outdent)
    end
    
    def indent(packet, opts = {})
      move(packet, false, :direction => :indent)
    end
    
    def home(packet, opts = {})
      if(opts[:subsite])
        site_id = opts[:orange_site_id] || packet['subsite'].blank? ? packet['site'].id : packet['subsite'].id
      else
        site_id = opts[:orange_site_id] || packet['site'].id 
      end
      model_class.home_for_site(site_id) || create_home_for_site(site_id)
    end
    
    def create_home_for_site(site_id)
      model_class.create_home_for_site(site_id)
    end
    
    def two_level(packet)
      do_view(packet, :two_level, :model => home(packet))
    end
    
    def routes_for(packet, opts = {})
      keys = {}
      keys[:resource] = opts[:resource] || packet['route.resource'] 
      keys[:resource_id] = opts[:resource_id] || packet['route.resource_id'] 
      keys[:orange_site_id] = opts[:orange_site_id] || packet['subsite'].blank? ? packet['site'].id : packet['subsite'].id
      keys.delete_if{|k,v| v.blank? }
      model_class.all(keys)
    end
    
    def add_link_for(packet)
      linky = ['add_route']
      linky << (packet['subsite'].blank? ? (packet['site'].blank? ? '0' : packet['site'].id) : packet['subsite'].id)
      linky << (packet['route.resource'].blank? ? '0' : packet['route.resource'])
      linky << (packet['route.resource_id'].blank? ? '0' : packet['route.resource_id'])
      packet.route_to(:sitemap, linky.join('/') )
    end
    
    def add_route_for(packet, opts = {})
      unless opts.blank?
        me = model_class.new(opts)
        me.save
        me.move(:into => home(packet, opts))
      end
    end
    
    def url_for(packet, opts = {})
      include_subsite = opts.delete(:include_subsite) || false
      m = model_class.first(opts)
      if !packet['subsite'].blank? && include_subsite
        return orange[:subsites].url_for(packet).gsub(/\/$/, '') + (m ? m.full_path : '#not_found')
      else
        return (m ? m.full_path : '#not_found')
      end
    end
    
    def add_route(packet, opts = {})
      args = packet['route.resource_path'].split('/')
      args.shift
      args = [:orange_site_id, :resource, :resource_id, :slug].inject_hash{|results, key|
        results[key] = args.shift
      }
      me = model_class.new(args)
      me.save
      me.move(:into => home(packet))
      packet.reroute(@my_orange_name, :orange,  me.id, 'edit')
      do_view(packet, :add_route, {})
    end
    
    def slug_for(model, props)
      hash = model.attributes
      return slug(model.title) if hash.has_key?(:title)
      return slug(model.name) if hash.has_key?(:name)
      return 'route-'+model.id
    end
    
    def slug(str)
      str.downcase.gsub(/[']+/, "").gsub(/[^a-z0-9]+/, "-")
    end
    
    def find_list(packet, mode, *args)
      home(packet, :subsite => true).self_and_descendants
    end
    
    def table_row(packet, opts ={})
      opts[:route] = opts[:model] || find_one(packet, :table_row, opts[:id])
      resource = opts[:route].resource
      resource = resource.to_sym if resource
      if resource && orange[resource].respond_to?(:sitemap_row)
        opts.delete(:model)
        orange[resource].sitemap_row(packet, opts.merge(:resource_name => resource, :id => opts[:route].resource_id))
      else
        do_view(packet, :table_row, opts)
      end
    end
    
    def sitemap_links(packet, opts = {})
      packet.add_js('sitemap.js', :module => '_sitemap_')
      opts.with_defaults!({:list => routes_for(packet) })
      opts.merge!({:add_route_link => add_link_for(packet)})
      do_list_view(packet, :sitemap_links, opts)
    end
  end
end