require 'orange/middleware/base'
module Orange::Middleware
  
  class Rerouter < Base
    def packet_call(packet)
      begin
        pass packet
      rescue Orange::Reroute
        packet.finish
      end
    end
  end
end