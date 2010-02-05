require 'orange/middleware/base'
module Orange::Middleware
  
  # Middleware to recapture return info and put it back into the
  # packet. Since the Orange::Stack is all middleware, this is
  # important for adding after filters into the orange stack
  # that can interact with the returns of external apps
  # 
  # This middleware has been depreciated in favor of the 
  # Middleware::Base#recapture method.
  class Recapture < Base
    
    def packet_call(packet)
      ret = pass packet
      packet[:status]  = ret[0]
      packet[:headers] = ret[1]
      packet[:content] = ret[2].first
      ret
    end
    
  end
end