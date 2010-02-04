require 'orange/core'
require 'orange/resources/model_resource'
require 'orange/cartons/site_carton'
require 'dm-is-awesome_set'
module Orange
  class Route < SiteCarton
    id
    admin do
      text :slug
      text :link_text
      boolean :show_in_nav, :default => false, :display_name => 'Show in Navigation?'
    end
    orange do
      string :resource
      string :resource_id
      string :resource_action
      boolean :accept_args, :default => true
    end
    include DataMapper::Transaction::Resource # Make sure Transactions are included (for awesome_set)
    is :awesome_set, :scope => [:orange_site_id]
    
    def full_path
      self_and_ancestors.inject('') do |path, part| 
        if part.parent # Check if this is a child
          path = path + part.slug + '/' 
        else  # The root slug is just the initial '/'
          path = path + '/' 
        end
      end
    end
  end
  
  class SitemapResource < ModelResource
    use Orange::Route
    def afterLoad
      orange[:admin, true].add_link('Content', :resource => @my_orange_name, :text => 'Sitemap')
    end
    
    def route(packet)
      resource = packet['route.resource']
      raise 'resource not found' unless orange.loaded? resource
      unless (packet['route.resource_action'])
        packet['route.resource_action'] = (packet['route.resource_id'] ? :show : :index)
      end
      
      packet[:content] = (orange[resource].view packet)
    end
    
    def route?(packet, path)
      parts = path.split('/')
      pad = parts.shift
      matched = home(packet)
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
      return false if(extras.length > 0 && !matched.accept_args)
      packet['route.path'] = path
      packet['route.route'] = matched
      packet['route.resource'] = matched.resource.to_sym
      packet['route.resource_id'] = matched.resource_id.to_i unless matched.resource_id.empty?
      packet['route.resource_action'] = matched.resource_action.to_sym unless matched.resource_action.empty? 
      # allow "resource_paths" - extra arguments added as path parts
      packet['route.resource_path'] = extras
      return true
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, *opts)
      if packet.request.post?
        params = packet.request.params[@my_orange_name.to_s]
        params.merge!(:orange_site_id => packet['site'].id)
        a = model_class.new(params)
        a.move(:into => home(packet))
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def higher(packet, opts = {})
      if packet.request.post?
        me = find_one(packet, :higher, packet['route.resource_id'])
        me.move(:higher) if me
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def lower(packet, opts = {})
      if packet.request.post?
        me = find_one(packet, :lower, packet['route.resource_id'])
        me.move(:lower) if me
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def outdent(packet, opts = {})
      if packet.request.post?
        me = find_one(packet, :outdent, packet['route.resource_id'])
        me.move(:outdent) if me
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def indent(packet, opts = {})
      if packet.request.post?
        me = find_one(packet, :indent, packet['route.resource_id'])
        me.move(:indent) if me
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def top_nav
      
    end
    
    def home(packet)
      site_id = packet['site'].id
      home_for_site(site_id) || create_home_for_site(site_id)
    end
    
    def home_for_site(site_id)
      model_class.root(:orange_site_id => site_id) 
    end
    
    def create_home_for_site(site_id)
      home = model_class.new({:orange_site_id => site_id, :slug => '_index_', :accept_args => false, :link_text => 'Home'})
      home.move(:root)
      home.save
      home
    end
    
    def find_list(packet, mode)
      home(packet).self_and_descendants
    end
  end
end