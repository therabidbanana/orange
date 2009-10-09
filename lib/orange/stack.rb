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
      instance_eval(&block) if block_given?
    end

    def use(middleware, *args, &block)
      @build.use(middleware, *args, &block)
    end
    
    def stack(middleware, *args, &block)
      @build.use(middleware, args.unshift(@core), &block)
    end
    
    def auto_reload!(val = true)
      @auto_reload = val
    end

    def run(app)
      @build.run(app)
    end

    def map(path, &block)
      @build.map(path, &block)
    end

    def call(env)
      env['orange.core'] = @core
      @app ||= @build.to_app                      # Build if necessary
      @app = @auto_reload ? @build.to_app : @app  # Rebuild if auto_reload is on.
      @app.call(env)
    end
  end
end
