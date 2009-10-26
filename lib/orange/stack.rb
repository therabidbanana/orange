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
      stack Orange::Middleware::Static, *args
      stack Orange::Middleware::RouteSite, *args
      stack Orange::Middleware::RouteContext, *args
    end

    def run(app)
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
    end

    def call(env)
      env['orange.core'] = @core
      app.call(env)
    end
  end
end
