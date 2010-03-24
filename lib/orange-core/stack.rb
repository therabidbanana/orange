require 'orange-core/core'
require 'rack/builder'
module Orange
  # Builds an orange stack of middleware
  # Use in the rackup file as follows:
  # app = Orange::Stack.new do 
  #    stack Orange::DataMapper 'sqlite3::memory:'  <= loads orange specific middleware
  #    use OtherMiddleware
  #    run SomeApp.new
  # end
  # run app
  #
  # All middleware placed inside the Orange::Stack will have access
  # to the Orange Core (as long as it's been written to accept it as the second
  # initialization argument) when added with the 'stack' method
  # 
  # In general, Orange::Stack works like Rack::Builder.
  class Stack
    
    # Creates a new Orange::Stack out of the passed block.
    # 
    # If a block is not passed, it will try to build one from scratch.
    # The bare minimum will be `run app_class.new(@core)`, there are also
    # other stacks that can be used.
    #
    # @param [Orange::Application] app_class the class of the main application
    # @param [Orange::Core] core the orange core
    # @param [Symbol] prebuilt the optional prebuilt stack, if one isn't passed as block
    def initialize(app_class = nil, core = false, prebuilt = :none, &block)
      @build = Rack::Builder.new
      @core = core || Orange::Core.new
      @auto_reload = false
      @middleware = []
      @recapture = true
      @main_app = app_class
      if block_given?
        instance_eval(&block) 
      else
        @main_app = app_class.new(@core) unless app_class.nil? 
        prebuild(prebuilt)
      end
    end
    
    # Runs methods necessary to build a stack. Don't use if a stack
    # has already been built by the initialize block.
    #
    # @todo Offer more choices for default stacks
    def prebuild(choice)
      case choice
      when :none
        run @main_app
      else
        run @main_app
      end
    end
    
    # Returns the main application instance that was added by the 
    # run method. Obviously won't return anything useful if the
    # middleware stack hasn't been set up with an explicit exit point,
    # as could be the case for a pure orange middleware stack on 
    # top of a different exit application (like Sinatra or Rails)
    def main_app
      @main_app
    end
    
    # Adds middleware using the Rack::Builder#use method
    # @param [Object] middleware A class of middleware that meets rack middleware requirements
    def use(middleware, *args, &block)
      @build.use(middleware, *args, &block)
    end
    
    # Loads resources into the core using the Orange::Core#load method
    # 
    # all args are passed on
    def load(*args, &block)
      orange.load(*args, &block)
    end
    
    # Adds Orange-aware middleware using the Rack::Builder#use method, adding
    # the orange core to the args passed on
    def stack(middleware, *args, &block)
      @build.use(middleware, @core, *args, &block)
    end
    
    # Set the auto_reload option, called without args, defaults to true,
    # other option is to set it to false
    def auto_reload!(val = true)
      @auto_reload = val
    end
    
    # Shortcut for adding Orange::Middleware::ShowExceptions to the middleware
    # stack
    def use_exceptions
      stack Orange::Middleware::ShowExceptions
    end
    
    # Alias for use_exceptions
    def show_exceptions
      use_exceptions
    end
    
    # Turn off recapture middleware, which is normally just on top of the exit
    # point
    # @see Orange::Middleware::Recapture
    def no_recapture
      @recapture = false
    end
    
    # A shortcut for adding many of the routing middleware options
    # simultaneously. Includes:
    # * Orange::Middleware::Rerouter
    # * Orange::Middleware::Static
    # * Rack::AbstractFormat
    # * Orange::Middleware::RouteSite
    # * Orange::Middleware::RouteContext
    # 
    # All of these are passed the args hash to use as they will, except 
    # for Rack::AbstractFormat
    # 
    def prerouting(*args)
      opts = args.extract_options!
      stack Orange::Middleware::Globals
      stack Orange::Middleware::Loader
      stack Orange::Middleware::Rerouter, opts.dup
      stack Orange::Middleware::Static, opts.dup
      use Rack::AbstractFormat unless opts[:no_abstract_format] 
          # Must be used before non-destructive route altering done by Orange,
          # since all orange stuff is non-destructive
      stack Orange::Middleware::RouteSite, opts.dup
      stack Orange::Middleware::RouteContext, opts.dup
      stack Orange::Middleware::Database
      Orange.plugins.each{|p| p.middleware(:prerouting).each{|m| stack m, opts.dup} if p.has_middleware?}
    end
    
    # A shortcut for routing via Orange::Middleware::RestfulRouter and any plugins
    #
    # Any args are passed on to the middleware
    def routing(opts ={})
      stack Orange::Middleware::RestfulRouter, opts.dup
      Orange.plugins.each{|p| p.middleware(:routing).each{|m| stack m, opts.dup} if p.has_middleware?}
      stack Orange::Middleware::FourOhFour, opts.dup
    end
    
    def postrouting(opts ={})
      Orange.plugins.each{|p| p.middleware(:postrouting).each{|m| stack m, opts.dup} if p.has_middleware?}
      stack Orange::Middleware::Template
    end
    
    def responders(opts ={})
      Orange.plugins.each{|p| p.middleware(:responders).each{|m| stack m, opts.dup} if p.has_middleware?}
    end
    
    # # A shortcut to enable Rack::OpenID and Orange::Middleware::AccessControl
    #     # 
    #     # Args will be passed on to Orange::Middleware::AccessControl
    #     def openid_access_control(*args)
    #       opts = args.extract_options!
    #       
    #     end
    
    # Adds pulp to the core via the Orange::Core#add_pulp method
    # @param [Orange::Mixin] mod a mixin to be included in the packet
    def add_pulp(mod)
      orange.add_pulp(mod)
    end
    
    # The exit point for the middleware stack,
    # add the app to @main_app and then call Rack::Builder#run with the main app
    def run(app, *args)
      opts = args.extract_options!
      @main_app = app
      @build.run(app)
    end
    
    # Returns the Orange::Core
    # @return [Orange::Core] The orange core 
    def orange
      @core
    end

    # Passes through to Rack::Builder#map
    # @todo Make this work - passing the block on to builder 
    #   means we can't intercept anything, which will yield 
    #   unexpected results
    def map(path, &block)
      raise 'not yet supported'
      @build.map(path, &block)
    end
    
    # Builds the middleware stack (or uses a cached one)
    # 
    # If auto_reload is enabled ({#auto_reload!}), builds every time
    #
    # @return [Object] a full stack of middleware and the exit application,
    #   conforming to Rack guidelines
    def app
      if @auto_reload
        orange.fire(:stack_reloading, @app) if orange.stack  # Alert we are rebuilding
        @app = false                    # Rebuild no matter what if autoload
      end
      unless @app 
        @app = @build.to_app            # Build if necessary
        orange.stack self
        orange.fire(:stack_loaded, @app)
      end
      @app
    end
    
    # Sets the core and then passes on to the stack, according to standard 
    # rack procedure
    def call(env)
      env['orange.core'] = @core
      app.call(env)
    end
  end
end
