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
      path_info = env['orange.env']['route.path'] || env['PATH_INFO']
      path = path_info.split('/')
      pad = path.shift # Shift off empty first part
      if path.empty?
        env['orange.env']['route.context'] = @default
      else
        if(@contexts.include?(path.first.to_sym))
          env['orange.env']['route.context'] = path.shift.to_sym
          path.unshift(pad)
          env['orange.env']['route.path'] = path.join('/')
        else
          env['orange.env']['route.context'] = @default
        end
      end
      @app.call(env)
    end
  end
end