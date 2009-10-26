require 'orange/middleware/base'

module Orange::Middleware
  # This middleware handles setting orange.env['route.site_url'] 
  # to a value based on the route, if any. The route is then 
  # trimmed before continuing on.
  # 
  # Options - 
  #   :multi   - does Orange need to handle multiple urls
  #   :fake_it - host url(s) that Orange will fake requests on
  #               ex: :multi => true, :fake_it => 'localhost'
  #                   will fake hostnames as first component of url
  #                   only on localhost
  class RouteSite < Base
    def initialize(app, core, *args)
      opts = args.extract_options!
      opts.with_defaults!(:multi => false, :fake_it => ['localhost'])
      @app = app
      @core = core
      @multi = opts[:multi]
      # Put fake_it into an array, if necessary
      @fake_it = opts[:fake_it].respond_to?(:include?) ? 
        opts[:fake_it] : [opts[:fake_it]]
    end
    
    def packet_call(packet)
      request = packet.request
      path_info = packet['route.path'] || packet.env['PATH_INFO']
      path = path_info.split('/')
      pad = path.shift # Shift off empty first part
      packet['route.faked_site'] = false
      if @multi
        if path.empty?
          packet['route.site_url'] = request.host
        else
          if @fake_it.include?(request.host)
            packet['route.site_url'] = path.shift
            packet['route.faked_site'] = true
          else
            packet['route.site_url'] = request.host
          end
          path.unshift(pad)
          packet['route.path'] = path.join('/')
        end
      else
        packet['route.site_url'] = request.host
      end
      @app.call(packet.env)
    end
  end
end