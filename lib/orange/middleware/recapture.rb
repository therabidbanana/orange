require 'orange/middleware/base'

module Orange::Middleware
  class Recapture < Base
        
    def packet_call(packet)
      ret = pass packet
      packet[:status] = ret[0]
      packet[:headers] = ret[1]
      packet[:content] = ret[2].first
      ret
    end
    
  end
end