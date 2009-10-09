require 'orange/middleware/base'

module Orange::Middleware
  class RestfulRouter < Base
    def init(*args)
      opts = args.extract_options!.with_defaults(:contexts => [:admin, :orange], :root_resource => :not_found)
      @contexts = opts[:contexts]
      @root_resource = opts[:root_resource]
    end
    
    def packet_call(packet)
      pass packet if packet['route.router'] # Don't route if other middleware
                                            # already has
      if(@contexts.include?(packet['route.context']))
        path = packet['route.path'] || packet.request.path_info
        parts = path.split('/')
        pad = parts.shift
        if !parts.empty?
          resource = parts.shift.to_sym
          if orange.loaded?(resource)
            packet['route.resource'] = resource
            if !parts.empty?
              second = parts.shift
              if second =~ /^\d+$/
                packet['route.resource_id'] = second
                if !parts.empty?
                  packet['route.resource_slice'] = parts.shift.to_sym
                end
              else
                packet['route.resource_slice'] = second.to_sym
              end
            end
          end
        end
      end
      packet['route.resource'] ||= @root_resource
      packet['route.resource_path'] = parts.unshift(pad).join('/')
      packet['route.router'] = self
      pass packet
    end
  end
end