require 'orange-core/middleware/base'

module Orange::Middleware
  # This middleware handles setting orange.env['route.context'] 
  # to a value based on the route, if any. The route is then 
  # trimmed before continuing on.
  class RouteContext < Base
    def initialize(app, core, *args)
      opts = args.extract_options!
      opts.with_defaults!(:contexts => [:live, :admin, :orange], 
                          :default => :live,
                          :urls => {})
      @app = app
      @core = core
      @contexts = opts[:contexts]
      @default = opts[:default]
      @urls = opts[:urls]
    end
    def packet_call(packet)
      path_info = packet['route.path'] || packet.env['PATH_INFO']
      path = path_info.split('/')
      pad = path.shift # Shift off empty first part
      if @urls[packet.request.host]
        packet['route.context'] = urls[packet.request.host]
      elsif path.empty?
        packet['route.context'] = @default
      else
        if(@contexts.include?(path.first.to_sym))
          packet['route.context'] = path.shift.to_sym
          path.unshift(pad)
          packet['route.path'] = path.join('/')
        else
          packet['route.context'] = @default
        end
      end
      pass packet
    end
  end
end