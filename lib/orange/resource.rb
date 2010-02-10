require 'orange/core'

module Orange
  # Orange Resource for being subclassed
  class Resource
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
      @my_orange_name
    end
    
    def options
      @options
    end
  end
end