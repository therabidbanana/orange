require 'orange-core/magick'
require 'orange-core/core'
module Orange::Plugins
  # This class defines a basic Orange plugin. A plugin simply defines
  # a bunch of possible classes/files that can be called up by the main
  # orange system.
  # 
  # The plugins are used in several places. When the core is initialized,
  # it will ask all plugins if they have any resources that should be added,
  # and load those resources if they exist.
  # 
  # The stack will call the list of plugins several times in building a stack
  # once for each possible middleware location. 
  class Base
    extend ClassInheritableAttributes
    cattr_accessor  :prerouting_middleware, :routing_middleware, 
                    :responder_middleware, :postrouting_middleware, :has_middleware
    cattr_accessor :assets, :assets_name
    cattr_accessor :resources
    cattr_accessor :views
    cattr_accessor :templates
    
    # Adds a single prerouting middleware class to list of prerouting middleware
    def self.prerouter(r)
      prerouters(r)
    end
    
    # Adds several prerouting middleware classes to list of prerouting middleware
    def self.prerouters(*routers)
      self.has_middleware = true
      routers.each do |prerouter|
        self.prerouting_middleware << prerouter
      end
    end
    
    # Adds a single postrouting middleware class to list of postrouting middleware
    def self.postrouter(r)
      postrouters(r)
    end
    
    # Adds several postrouting middleware classes to list of postrouting middleware
    def self.postrouters(*routers)
      self.has_middleware = true
      routers.each do |postrouter|
        self.postrouting_middleware << postrouter
      end
    end
    
    # Adds a router middleware class to the list of routing middleware
    def self.router(r)
      routers(r)
    end
    # Adds several router middleware classes
    def self.routers(*routers)
      self.has_middleware = true
      routers.each do |router|
        self.routing_middleware << router
      end
    end
    # Adds a responder middleware class 
    def self.responder(r)
      responders(r)
    end
    # Adds several responder middleware classes
    def self.responders(*respones)
      self.has_middleware = true
      respones.each do |response|
        self.responder_middleware << response
      end
    end
    
    # Returns the list of prerouting_middleware defined or
    # an empty array if none defined
    def self.prerouting_middleware
      super || self.prerouting_middleware = []
    end
    
    # Returns the list of prerouting_middleware defined or
    # an empty array if none defined
    def self.postrouting_middleware
      super || self.postrouting_middleware = []
    end
    
    # Returns the list of routing_middleware defined or
    # an empty array if none defined
    def self.routing_middleware
      super || self.routing_middleware = []
    end
    
    # Returns the list of responder_middleware defined or
    # an empty array if none defined
    def self.responder_middleware
      super || self.responder_middleware = []
    end
    
    def self.templates_dir(arg)
      self.templates = arg
    end
    
    def self.views_dir(arg)
      self.views = arg
    end
    
    def self.assets_dir(arg)
      self.assets = arg
    end
    
    def self.resource(name, instance)
      self.resources[name] = instance
    end
    
    def self.resources
      super || self.resources = {}
    end
    
    # Returns the assigned asset dir name,
    # or Plugin class name formatted like this: PluginClass -> _pluginclass_
    def assets_name
      self.class.assets_name || '_'+self.class.to_s.gsub(/Orange::Plugins::/, '').gsub(/::/, '_').downcase+'_'
    end
    
    # Returns the assets directory for this plugin
    def assets
      self.class.assets
    end
    
    # Whether this plugin has assets for the static middleware to worry
    # about
    def has_assets?
      !assets.blank?
    end
    
    def resources
      self.class.resources
    end
    
    def has_resources?
      !resources.blank?
    end
    
    def views
      self.class.views
    end
    
    def has_views?
      !views.blank?
    end
    
    def templates
      self.class.templates
    end
    
    def has_templates?
      !templates.blank?
    end
    
    def middleware(type = :has)
      case type
      when :responders then self.class.responder_middleware
      when :routing then self.class.routing_middleware
      when :prerouting then self.class.prerouting_middleware
      when :postrouting then self.class.postrouting_middleware
      when :has then self.class.has_middleware
      else nil
      end
    end
    
    def has_middleware?
      !middleware.blank?
    end
  end
end