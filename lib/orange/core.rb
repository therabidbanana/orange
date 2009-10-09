# This is the class that acts as the Rack responder
require 'rubygems'
require 'dm-core'

require 'rack'
require 'rack/builder'
Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each {|f| require f }
Dir.glob(File.join(File.dirname(__FILE__), 'middleware', '*.rb')).each {|f| require f }

module Orange
  def self.load_db!(url)
    DataMapper.setup(:default, url)
    DataMapper.auto_upgrade!
  end
  class Core
    # Sets the default options for Orange Applications
    DEFAULT_CORE_OPTIONS = 
      {
        :contexts => [:live, :admin, :orange],
        :default_context => :live,
        :default_resource => :not_found,
        :default_database => 'sqlite3::memory:'
      }
      
    def self.static_url;      "_orange_";             end
    def self.static_dir;      $ORANGE_ASSETS;         end
    
    # Args will be set to the @options array. 
    # Block DSL style option setting also available:
    #
    #   orange = Orange::Core.new(:optional_option => 'foo') do
    #     haml true
    #     site_name "Banana"
    #     custom_router MyRouterClass.new
    #   end
    #
    #   orange.options[:site_name] #=> "Banana"
    def initialize(app = false, *args, &block)
      @app = app
      @options = Options.new(*args, &block).hash.with_defaults(DEFAULT_CORE_OPTIONS)
      @resources = {}
      @events = {}
      load(Parser.new, :parser)
      if @options[:custom_router]
        load(@options[:custom_router], :orange_router)
      else
        load(Router.new)
      end
      unless @options[:no_database]
        db = @options[:database] || @options[:default_database]
        DataMapper.setup(:default, db)
        DataMapper.auto_migrate!
      end
      load(NotFoundHandler.new, :not_found)
      afterLoad
      self
    end
    
    def afterLoad
      true
    end
    
    # Responds to the Rack interface. Routes the packet with the
    # configured router, fires the routed event, then 
    # returns a tuple of [status, headers, content]
    def call(env)
      env['orange.core'] ||= self
      packet = Packet.new(orange, env)
      env['orange.packet'] ||= packet
      # begin
      #   
      #   Orange::load_db!("sqlite3://#{Dir.pwd}/db/orangerb.sqlite3")
      #   orange.fire(:before_route, packet)
      #   packet.route
      #   orange.fire(:enroute, packet)
      # rescue Orange::Reroute => e
      #   packet[:content] = ''
      # end
      # packet.finish
      puts @app
      @app.call(env)
    end
    
    # Takes an instance of a Orange::Resource subclass, sets orange
    # then adds it to the orange resources
    def load(resource, name = false)
      name = resource.class.to_s.gsub(/::/, '_').downcase.to_sym if(!name) 
      @resources[name] = resource.set_orange(self, name)
    end
    
    # Returns self for consistent naming
    def orange
      self
    end
    
    # Registers a callback
    def register(event, position = 0, &block)
      if block_given?
        if @events[event] 
          @events[event].insert(position, block)
        else
          @events[event] = Array.new.insert(position, block)
        end
      end
    end
    
    # Fires a callback for a given packet
    def fire(event, packet)
      return false unless @events[event]
      @events[event].compact!
      for callback in @events[event]
        callback.call(packet)
      end
    end
    
    # Returns options of the orange core
    def options
      @options
    end
    
    # Accesses resources array
    def [](name)
      @resources[name]
    end
    
    def mixin(inc)
      Packet.mixin inc
    end
    
    def inspect
      self.to_s
    end
  end
end