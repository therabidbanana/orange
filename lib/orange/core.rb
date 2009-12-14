require 'dm-core'
require 'rack'
require 'rack/builder'

module Orange
  # Declare submodules for later use
  module Pulp; end
  module Mixins; end
  
  # Allow mixins directly from Orange
  def self.mixin(inc)
    Core.mixin inc
  end
  
  # Allow pulp directly from Orange
  def self.pulp(inc)
    Packet.mixin inc
  end
  
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
      @file = __FILE__
      load(Orange::Parser.new, :parser)
      load(Orange::Mapper.new, :mapper)
      afterLoad
      self
    end
    
    def core_dir
      File.dirname(__FILE__)
    end
    
    def afterLoad
      true
    end
    
    def loaded?(resource_name)
      @resources.has_key?(resource_name)
    end
    
    # Takes an instance of a Orange::Resource subclass, sets orange
    # then adds it to the orange resources
    def load(resource, name = false)
      name = resource.class.to_s.gsub(/::/, '_').downcase.to_sym if(!name) 
      @resources[name] = resource.set_orange(self, name)
    end
    
    # Convenience self for consistent naming across middleware
    def orange;     self;     end
    
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
    
    def add_pulp(inc)
      self.class.add_pulp inc
    end
    
    def mixin(inc)
      self.class.mixin inc
    end
    
    def self.mixin(inc)
      include inc
    end
    
    def self.add_pulp(inc)
      Packet.mixin inc
    end
  end
end