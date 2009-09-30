# This is the class that acts as the Rack responder

require 'rack'
require 'rack/builder'
require 'orange/magick'
require 'orange/parser'
require 'orange/router'
require 'orange/context'

module Orange
  class Core
    def initialize(*args, &block)
      @options = Options.new(args, &block).hash
      @resources = {}
      load(Parser.new, :parser)
      load(Router.new, :router)
    end

    def call(env)
      context = Context.new(orange, env)
      content = orange[:router].route(context)
      headers = context[:headers].with_defaults({'Content-Type' => 'text/html'})
      [200, headers, content ]
    end
    
    # Takes an instance of a Orange::Resource subclass, sets orange
    # then adds it to the orange resources
    def load(resource, name = false)
      name = resource.class.to_s.split('::').last.downcase.to_sym if(!name) 
      @resources[name] = resource.set_orange(self, name)
    end
    
    def orange
      self
    end
    
    def [](name)
      @resources[name]
    end
  end
end