# This is the class that acts as the Rack responder

require 'rack'
require 'rack/builder'
require 'orange/magick'
require 'orange/parser'
require 'orange/router'
require 'orange/packet'

module Orange
  class Core
    # Sets the default options for Orange Applications
    DEFAULT_CORE_OPTIONS = 
      {
        :contexts => [:live, :admin],
        :default_context => :live,
        :default_resource => :not_found
      }
    
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
    def initialize(*args, &block)
      @options = Options.new(*args, &block).hash.with_defaults(DEFAULT_CORE_OPTIONS)
      @resources = {}
      @events = {}
      load(Parser.new, :parser)
      if @options[:custom_router]
        load(@options[:custom_router], :router)
      else
        load(Router.new)
      end
      load(NotFoundHandler.new, :not_found)
      afterLoad
    end
    
    def afterLoad
      true
    end
    
    # Responds to the Rack interface. Routes the packet with the
    # configured router, fires the routed event, then 
    # returns a tuple of [status, headers, content]
    def call(env)
      packet = Packet.new(orange, env)
      orange[:orange_router].route(packet)
      orange.fire(:enroute, packet)
      packet.finish
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
    
  end
end