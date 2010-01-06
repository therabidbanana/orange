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
      boolean :show_in_nav, :default => false, :display_name => 'Show?'
    end
    orange do
      string :resource
      string :resource_id
    end
    include DataMapper::Transaction::Resource # Make sure Transactions are included
    is :awesome_set, :scope => [:orange_site_id]
    
  end
  
  class SitemapResource < ModelResource
    use Orange::Route
    def afterLoad
      orange[:admin, true].add_link('Content', :resource => @my_orange_name, :text => 'Sitemap')
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
      model_class.first(:slug => '_index_', :orange_site_id => site_id, :order => :lft.asc) 
    end
    
    def create_home_for_site(site_id)
      home = model_class.new({:orange_site_id => site_id, :slug => '_index_'})
      home.move(:root)
      home.save
      home
    end
    
    def find_list(packet, mode)
      Orange::Route.all(:order => :lft) || []
    end
  end
end