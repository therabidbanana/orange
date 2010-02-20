require 'orange-core/packet'

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
    # Initialize will set the core and downstream app, then call init
    # subclasses should override init instead of initialize
    # @param [Object] app a downstream app 
    # @param [Orange::Core] core the orange core
    # @param [optional, Array] args any arguments
    def initialize(app, core, *args)
      @app = app
      @core = core
      init(*args)
    end
    
    # A stub method that subclasses can override to handle initialization
    # @return [void]
    def init(*args)
    end
    
    # The standard Rack "call". By default, Orange Middleware wraps the env into
    # an Orange::Packet and passes it on to #packet_call. Subclasses will typically
    # override packet_call rather than overriding call directly. 
    # 
    # Orange Middleware
    # should expect to have this method ignored by upstream Orange-aware apps in
    # favor of calling packet_call directly.
    # @param [Hash] env the hash of environment variables given by the rack interface.
    # @return [Array] the standard Rack striplet of status, headers and content
    def call(env)
      packet = Orange::Packet.new(@core, env)
      packet_call(packet)
    end
    
    # Like the standard call, but with the env hash already wrapped into a Packet
    # This is called automatically as part of #call, so subclasses can have a packet
    # without having to initialize it. It will be called directly by Orange-aware
    # upstream middleware, skipping the step of initializing the packet during #call.
    # 
    # Passing the packet downstream should be done with #pass rather than the Rack
    # standard @app.call, since #pass will take the packet and do a #packet_call
    # if possible.
    # @param [Orange::Packet] packet the packet corresponding to this env
    # @return [Array] the standard Rack striplet of status, headers and content
    def packet_call(packet)
      pass packet
    end
    
    # Pass will sent the packet to the downstream app by calling call or packet call.
    # Calling pass on a packet is the preferred way to call downstream apps, as it
    # will call packet_call directly if possible (to avoid reinitializing the packet)
    # @param [Orange::Packet] packet the packet to pass to downstream apps
    # @return [Array] the standard Rack striplet of status, headers and content
    def pass(packet)
      if @app.respond_to?(:packet_call)
        @app.packet_call(packet)
      else
        recapture(@app.call(packet.env), packet)
      end
    end
    
    # After the pass has been completed, we should recapture the contents and make
    # sure they are placed in the packet, in case the downstream app is not Orange aware.
    # @param [Array] the standard Rack striplet of status, headers and content
    # @param [Orange::Packet] packet the packet to pass to downstream apps
    # @return [Array] the standard Rack striplet of status, headers and content
    def recapture(response, packet)
      packet[:status]  = response[0]
      packet[:headers] = response[1]
      packet[:content] = response[2].first
      response
    end
    
    # Accessor for @core, which is the stack's instance of Orange::Core
    # @return [Orange::Core] the stack's instance of Orange::Core
    def orange;     @core;    end
    
    # Help stack traces
    # @return [String] string representing this middleware (#to_s)
    def inspect
      self.to_s
    end
  end
end