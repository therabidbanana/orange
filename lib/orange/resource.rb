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
    
    def afterLoad
      true
    end
    
    def orange
      @orange
    end
    
    def routable
      false
    end
    
    def view(type = :none)
      ''
    end
  end
end