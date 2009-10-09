require 'orange/packet'

# Orange Middleware is a bit more complex than Rack middleware. 
# Initializing it requires both a link to the downstream app and 
# the core, and calling the app often requires an Orange::Packet
#
# Orange::Middleware::Base takes care of these basic tasks.
# Subclasses override the init method for extra initialization
# and the packet_call for a call with a packet, rather than
# a basic call
module Orange::Middleware
  class Base
    def initialize(app, core)
      @app = app
      @core = core
      init
    end
    
    def init
    end
    
    def call(env)
      packet = Orange::Packet.new(@core, env)
      packet_call(packet)
    end
    
    def packet_call(packet)
    end
  end
end