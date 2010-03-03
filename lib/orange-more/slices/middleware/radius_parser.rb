require 'orange-core/middleware/base'

module Orange::Middleware
  # The RadiusParser middleware will parse all outgoing content with 
  # Radius.
  #
  # For more details on how Radius works, see http://radius.rubyforge.org/
  # This middleware also loads a resource: "Orange::Radius", for the
  # purpose of exposing the context object.
  class RadiusParser < Base
    def init(opts = {})
      @contexts = opts[:contexts] || [:live]
      orange.load Orange::Radius.new, :radius
    end
    
    # Passes packet then parses the return
    def packet_call(packet)
      pass packet
      orange[:radius].parse packet if @contexts.include? packet['route.context']
      packet.finish
    end
    
  end
end