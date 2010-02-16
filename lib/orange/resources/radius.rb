require 'radius'

module Orange
  # Radius resource is for exposing the Radius context
  # and allowing parsing.
  class Radius < Resource
    def afterLoad
      @context = ::Radius::Context.new
    end
    
    def context
      @context
    end
    
    def parse(packet)
      content = packet[:content, false]
      unless content.blank? 
        parser = ::Radius::Parser.new(context, :tag_prefix => 'o')
        packet[:content] = parser.parse(content)
      end
    end
  end
end