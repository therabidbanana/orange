module Orange
  class Router < Resource
    # Takes a packet extracts request information, then calls packet.route
    def route(packet)
      # Path parts minus the initial empty string at the front
      path_parts = packet.request.path.split('/')
      path_parts.shift
      
      # Extract potential context, if any
      context = path_parts[0].respond_to?(:to_sym) ? 
        path_parts[0].to_sym : :context_not_found
      if(orange.options[:contexts].include?(context))
        packet[:context] = path_parts.shift.to_sym
      else
        packet[:context] = orange.options[:default_context]
      end
      
      # Extract potential resource
      resource = path_parts[0].respond_to?(:to_sym) ? 
        path_parts[0].to_sym : :resource_not_found
      if(orange[resource] && orange[resource].routable)
        packet[:path_resource] = path_parts.shift.to_sym
      else
        packet[:path_resource] = orange.options[:default_resource]
      end
      
      remaining = path_parts.join('/')
      packet[:resource_path] = remaining
      
      # Try to route
      begin
        packet.route
      rescue Orange::Reroute => e
        packet[:content] = ''
      end
    end
    
  end
  
  class Reroute < Exception
    def initialize(packet)
      @packet = packet
      @packet[:headers] = {"Content-Type" => 'text/html', "Location" => self.url}
      @packet[:status] = 302
    end
    
    def url
      case packet[:reroute_type]
      when :real
        packet[:reroute_to]
      # Parsing for orange urls or something
      end
    end
    
    def packet
      @packet
    end
  end
  
  class RoutableResource < Resource
    def routable; true; end
    def route(path, packet = false)
      
    end
  end
  
  class NotFoundHandler < RoutableResource
    def route(path, packet = false)
      packet[:content] = orange[:parser].haml('404.haml', packet)
      packet[:status] = 404
    end
  end
end