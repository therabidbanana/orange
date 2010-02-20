require 'orange-core/middleware/base'

module Orange::Middleware
  # The FlexRouter middleware takes a resource that can route paths and
  # then intercepts routes for that resource. By default,
  # it uses the Orange::SitemapResource. 
  # 
  # The resource is automatically loaded into the core as 
  # :sitemap. The resource must respond to "route?(path)" 
  # and "route(packet)".  
  # 
  # Pass a different routing resource using the :resource arg
  class FourOhFour < Base
    def init(opts = {})
      @resource = opts[:resource] || Orange::NotFound
      orange.load @resource.new, :not_found
    end
    
    # Sets the sitemap resource as the router if the resource can accept 
    # the path.
    def packet_call(packet)
      packet['route.router'] = orange[:not_found] unless packet['route.router']
      pass packet
    end
    
  end
end