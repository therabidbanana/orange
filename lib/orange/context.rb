module Orange
  class Context
    def initialize(orange, env)
      @orange = orange
      @context = {}
      @context[:env] = env
      @context[:headers] = {}
    end
    
    def [](key)
      @context[key] || false
    end
  end
end