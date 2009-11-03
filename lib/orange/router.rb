module Orange
  
  class Reroute < Exception
    def initialize(packet)
      @packet = packet
      @packet[:headers] = {"Content-Type" => 'text/html', "Location" => self.url}
      @packet[:status] = 302
    end
    
    def url
      case packet['reroute.type']
      when :real
        packet['reroute.to']
      # Parsing for orange urls or something
      when :orange
        packet.route_to(packet['reroute.to'])
      end
    end
    
    def packet
      @packet
    end
  end
  
  class RoutableResource < Resource
    def routable; true; end
    def route(path, packet)
      parts = path.split('/')
      first = parts[0].respond_to?(:to_sym) ? parts.shift.to_sym : :index
      new_path = parts.join('/')
      if self.respond_to?(first)
        packet[:content] = self.__send__(first, new_path, packet)
      end
    end
  end
  
  class NotFoundHandler < RoutableResource
    def route(path, packet)
      packet[:content] = orange[:parser].haml('404.haml', packet)
      packet[:status] = 404
    end
  end
end