module Orange::Middleware
  # This middleware handles setting orange.env[:context] 
  # to a value based on the route, if any. The route is then 
  # trimmed before continuing on.
  class RouteContext
    def initialize(app, *args)
      opts = args.extract_options!
      opts.with_defaults!(:contexts => [:live, :admin, :orange], 
                          :default => :live)
      @app = app
      @contexts = opts[:contexts]
      @default = opts[:default]
    end
    def call(env)
      env['orange.env'] = {} unless env['orange.env']
      request = Rack::Request.new(env)
      path = request.path_info.split('/')
      pad = path.shift # Shift off empty first part
      if path.empty?
        env['orange.env'][:context] = @default
      else
        if(@contexts.include?(path.first.to_sym))
          env['orange.env'][:context] = path.shift.to_sym
          path.unshift(pad)
          request.path_info = path.join('/')
        else
          env['orange.env'][:context] = @default
        end
      end
      @app.call(env)
    end
  end
end