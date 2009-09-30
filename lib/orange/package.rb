module Orange
  class Package
    def initialize(orange, env)
      @orange = orange
      @response = {}
      @response[:env] = env
      @response[:headers] = {}
    end
    
    def [](key)
      @response[key] || false
    end
    
    def response
      @response
    end
  end
end