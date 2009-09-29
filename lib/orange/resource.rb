module Orange
  class Resource
    def initialize(*args, &block)
      @options = Options.new(args, &block).hash
    end
    
    def set_orange(orange, name)
      @orange = orange
      @my_orange_name = name
      self
    end
    
    def orange
      @orange
    end
  end
end