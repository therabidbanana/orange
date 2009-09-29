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
      load(Context.new, :context)
    end

    def call(env)
      
      reroute = orange[:router].route(env)
      r = orange[:parser].haml('index.haml', :env => env)
      [200, { 'Content-Type' => 'text/html' }, r ]
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