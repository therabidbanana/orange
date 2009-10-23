require 'orange/middleware/base'

module Orange::Middleware
  class RestfulRouter < Base
    def init(*args)
      opts = args.extract_options!.with_defaults(:contexts => [:admin, :orange], :root_resource => :not_found)
      @contexts = opts[:contexts]
      @root_resource = opts[:root_resource]
    end
    
    # sets resource, resource_id, resource_action and resource_path
    # /resource/id/action/[resource/path/if/any]
    # /resource/action/[resource/path/if/any]
    # 
    # In future - support for nested resources
    def packet_call(packet)
      return (pass packet) if packet['route.router']  # Don't route if other middleware
                                                      # already has
      if(@contexts.include?(packet['route.context']))
        path = packet['route.path'] || packet.request.path_info
        parts = path.split('/')
        pad = parts.shift
        if !parts.empty?
          resource = parts.shift
          if orange.loaded?(resource.to_sym)
            packet['route.resource'] = resource.to_sym
            if !parts.empty?
              second = parts.shift
              if second =~ /^\d+$/
                packet['route.resource_id'] = second
                if !parts.empty?
                  packet['route.resource_action'] = parts.shift.to_sym
                end
              else
                packet['route.resource_action'] = second.to_sym
              end 
            end # end check for second part
          else
            parts.unshift(resource)
          end # end check for loaded resource
        end # end check for nonempty route
        
        packet['route.resource'] ||= @root_resource
        packet['route.resource_path'] = parts.unshift(pad).join('/')
        packet['route.router'] = self
      end # End context match if
      
      pass packet
    end
  end
end