require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Rerouter < Base
    def init(*args)
      orange.add_pulp Orange::Pulp::Packet_Reroute
    end
    
    def packet_call(packet)
      begin
        pass packet
      rescue Orange::Reroute
        packet.finish
      end
    end
  end
end

module Orange
  
  module Pulp::Packet_Reroute
    def reroute(url, type = :real, *args)
      packet['reroute.to'] = url
      packet['reroute.type'] = type
      packet['reroute.args'] = *args if args
      raise Reroute.new(self), 'Unhandled reroute'
    end
  end
  
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
        packet.route_to(packet['reroute.to'], *packet['reroute.args', []])
      else
        packet['reroute.to']
      end
    end
    
    def packet
      @packet
    end
  end
end