require 'orange/router'

module Orange
  # By default, haml files are parsed in the context of their
  # packet. This means all of instance variables and functions should
  # be available to the haml parser.
  class Packet
    DEFAULT_HEADERS = {"Content-Type" => 'text/html'}
    
    def initialize(orange, env)
      @orange = orange
      @response = {}
      @response[:env] = env
      @response[:request] = Rack::Request.new(env)
      @response[:headers] = {}
    end
    
    def [](key, default = false)
      @response[key] || default
    end
    
    def []=(key, val)
      @response[key] = val
    end
    
    def headers
      @response[:headers].with_defaults(DEFAULT_HEADERS)
    end
    
    def content
      return [@response[:content]] if @response[:content]
      return []
    end
    
    def request
      @response[:request]
    end
    
    def html(&block)
      if block_given?
        doc = orange[:parser].hpricot(packet[:content])
        yield doc
        packet[:content] = doc.to_s
      end
    end
    
    def orange
      @orange
    end
    
    def finish
      headers = packet.headers
      status = packet[:status, 200]
      content = packet.content
      if content.respond_to?(:to_ary)
        headers["Content-Length"] = content.to_ary.
          inject(0) { |len, part| len + Rack::Utils.bytesize(part) }.to_s
      end
      [status, headers, content]
    end
    
    def packet
      self
    end
    
    def route
      resource = packet[:path_resource]
      orange[resource].route(:resource_path, packet)
    end
    
    def reroute(url, type = :real)
      @response[:reroute_to] = url
      @response[:reroute_type] = type
      raise Reroute.new(self), 'Unhandled reroute'
    end
  end
end