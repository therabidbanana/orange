require 'orange/router'

module Orange
  # By default, haml files are parsed in the context of their
  # packet. This means all of instance variables and functions should
  # be available to the haml parser.
  class Packet
    DEFAULT_HEADERS = {"Content-Type" => 'text/html'}
    
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
      @env['orange.env'][key] || default
    end
    
    def []=(key, val)
      @env['orange.env'][key] = val
    end
    
    def env
      @env
    end
    
    def headers
      packet[:headers].with_defaults(DEFAULT_HEADERS)
    end
    
    def content
      return [packet[:content]] if packet[:content]
      return []
    end
    
    def request
      packet[:request]
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
    
    def part
      packet[:page_parts] = Page_Parts.new unless packet[:page_parts]
      packet[:page_parts]
    end
    
    def admin_sidebar_link(section, *args)
      args = args.extract_options!.with_defaults(:position => 0)
      sidebar = part[:admin_sidebar, {}]
      sidebar[section] = [] unless sidebar[section]
      sidebar[section].insert(args[:position], {:href => args[:link], :text => args[:text]})
      part[:admin_sidebar] = sidebar
    end
    
    def add_css(file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
        # module set to false gives the root assets dir
      assets = File.join('assets', mod)
      file = File.join('', assets, 'css', file)
      if ie
        part[:ie_css] = part[:ie_css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
      else 
        part[:css] = part[:css] + "<link rel=\"stylesheet\" href=\"#{file}\" type=\"text/css\" media=\"screen\" charset=\"utf-8\" />"
      end
    end
    def add_js(file, opts = {})
      ie = opts[:ie] || false
      mod = opts[:module] || 'public'
      assets = File.join('assets', mod)
      file = File.join('', assets, 'js', file)
      if ie
        part[:ie_js] = part[:ie_js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
      else 
        part[:js] = part[:js] + "<script src=\"#{file}\" type=\"text/javascript\"></script>"
      end
    end
    
    def self.mixin(inc)
      include inc
    end
  end
  
  class Page_Parts < ::Hash
    def [](key, default = '')
      super(key) || default
    end
  end
end