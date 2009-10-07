module Orange::Middleware
  # This middleware handles setting orange.env[:site_url] 
  # to a value based on the route, if any. The route is then 
  # trimmed before continuing on.
  # 
  # Options - 
  #   :multi   - does Orange need to handle multiple urls
  #   :fake_it - host url(s) that Orange will fake requests on
  #               ex: :multi => true, :fake_it => 'localhost'
  #                   will fake hostnames as first component of url
  #                   only on localhost
  class RouteSite
    def initialize(app, *args)
      opts = args.extract_options!
      opts.with_defaults!(:multi => false, :fake_it => [false])
      @app = app
      @multi = opts[:multi]
      # Put fake_it into an array, if necessary
      @fake_it = opts[:fake_it].respond_to?(:include?) ? 
        opts[:fake_it] : [opts[:fake_it]]
    end
    
    def call(env)
      env['orange.env'] = {} unless env['orange.env']
      request = Rack::Request.new(env)
      path = request.path_info.split('/')
      pad = path.shift # Shift off empty first part
      if @multi
        if path.empty?
          env['orange.env'][:site_url] = request.host
        else
          if @fake_it.include?(request.host)
            env['orange.env'][:site_url] = path.shift
          else
            env['orange.env'][:site_url] = request.host
          end
          path.unshift(pad)
          request.path_info = path.join('/')
        end
      else
        env['orange.env'][:site_url] = request.host
      end
      @app.call(env)
    end
  end
end