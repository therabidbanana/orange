require 'orange/core'

module Orange
  # Orange Resource for being subclassed
  class Resource
    def initialize(*args, &block)
      @options = Options.new(args, &block).hash
    end
    
    def set_orange(orange, name)
      @orange = orange
      @my_orange_name = name
      afterLoad
      self
    end
    
    def self.set_orange(*args)
      raise 'trying to call set orange on a class (you probably need to instantiate a resource)'
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
    
    def view(packet = false)
      ''
    end
  end
end