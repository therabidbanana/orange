require 'orange-core/core'

module Orange
  # Orange Resource for being subclassed
  class Resource
    extend ClassInheritableAttributes
    # Defines a model class as an inheritable class attribute and also an instance
    # attribute
    cattr_inheritable :called
    
    def initialize(*args, &block)
      @options = DefaultHash.new.merge!(Options.new(*args, &block).hash)
    end
    
    def set_orange(orange, name)
      @orange = orange
      @my_orange_name = name
      afterLoad
      self
    end
    
    def self.set_orange(*args)
      raise 'instantiate the resource before calling set orange'
    end
    
    def afterLoad
      true
    end
    
    def self.call_me(name)
      self.called = name
    end
    
    def orange
      @orange
    end
    
    def routable
      false
    end
    
    def view(packet = false, *args)
      ''
    end
    
    def orange_name
      @my_orange_name || self.class.called || false
    end
    
    def options
      @options
    end
  end
end