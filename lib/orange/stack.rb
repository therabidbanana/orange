require 'orange/core'
require 'rack/builder'

# Builds an orange stack of middleware
# Use in the rackup file as follows:
# app = Orange::Stack.new do 
#    stack Orange::DataMapper 'sqlite3::memory:'  <= loads orange specific middleware
#    use OtherMiddleware
# end
# run app
#
# All middleware placed inside the Orange::Stack will automatically have access
# to the Orange Core (as long as it's been written to accept it as the second
# initialization argument)
module Orange
  class Stack
    def initialize(&block)
      @build = Rack::Builder.new
      @core = Orange::Core.new
      @auto_reload = false
      @recapture = true
      instance_eval(&block) if block_given?
    end

    def use(middleware, *args, &block)
      @build.use(middleware, *args, &block)
    end
    
    def load(*args)
      @core.load(*args)
    end
    
    def stack(middleware, *args, &block)
      @build.use(middleware, @core, *args, &block)
    end
        
    def auto_reload!(val = true)
      @auto_reload = val
    end
    def use_exceptions
      stack Orange::Middleware::ShowExceptions
    end
    def no_recapture
      @recapture = false
    end
    
    def prerouting(*args)
      opts = args.extract_options!
      stack Orange::Middleware::Rerouter, opts
      stack Orange::Middleware::Static, opts
      use Rack::AbstractFormat unless opts[:no_abstract_format] 
          # Must be used before non-destructive route altering done by Orange,
          # since all orange stuff is non-destructive
      stack Orange::Middleware::RouteSite, opts
      stack Orange::Middleware::RouteContext, opts
    end
    
    def restful_routing(*args)
      opts = args.extract_options!
      stack Orange::Middleware::RestfulRouter, opts
    end
    
    def openid_access_control(*args)
      opts = args.extract_options!
      require 'rack/openid'
      require 'openid_dm_store'

      use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
      stack Orange::Middleware::AccessControl, opts
    end
    
    def add_pulp(mod)
      orange.add_pulp(mod)
    end

    def run(app, *args)
      opts = args.extract_options!
      if @recapture
        stack Orange::Middleware::Recapture
        @recapture = false
      end
      @build.run(app)
    end
    
    def orange
      @core
    end

    def map(path, &block)
      @build.map(path, &block)
    end
    
    def app
      @app = false if @auto_reload      # Rebuild no matter what if autoload
      @app ||= @build.to_app            # Build if necessary
      orange.fire(:stack_loaded, @app)
      @app
    end

    def call(env)
      env['orange.core'] = @core
      app.call(env)
    end
  end
end
