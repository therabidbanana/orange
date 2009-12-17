module Orange
  # By default, haml files are parsed in the context of their
  # packet. This means all of instance variables and functions should
  # be available to the haml parser.
  class Packet
    DEFAULT_HEADERS = {"Content-Type" => 'text/html'} unless defined?(DEFAULT_HEADERS)
    
    def self.new(orange, env)
      return env['orange.packet'] if env['orange.packet']
      super(orange, env)
    end
    
    def initialize(orange, env)
      @orange = orange
      @env = env
      @env['orange.packet'] = self
      @env['orange.env'] = {} unless @env['orange.env']
      @env['orange.env'][:request] = Rack::Request.new(env)
      @env['orange.env'][:headers] = {}
    end
    
    def [](key, default = false)
      @env['orange.env'].has_key?(key) ? @env['orange.env'][key] : default
    end
    
    def []=(key, val)
      @env['orange.env'][key] = val
    end
    
    def env
      @env
    end
    
    def session
      env['rack.session']
    end
    
    def headers
      packet[:headers, {}].with_defaults(DEFAULT_HEADERS)
    end
    def header(key, val)
      @env['orange.env'][:headers][key] = val
    end
    
    def add_header(key, val)
      header key, val
    end
    
    def content
      return [packet[:content]] if packet[:content]
      return []
    end
    
    def request
      packet[:request]
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
    
    def self.mixin(inc)
      include inc
    end
    
    def route
      router = packet['route.router']
      raise 'Router not found' unless router
      router.route(self)
    end
  end
  
end