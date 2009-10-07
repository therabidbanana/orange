require 'orange/resource'

module Orange
  class Router < Resource
    # Takes a packet extracts request information, then calls packet.route
    def afterLoad
      orange.mixin Packet_Router
      orange.register(:before_route, 99) do |packet|
        # Path parts minus the initial empty string at the front
        path_parts = packet.request.path.split('/')
        path_parts.shift

        # Extract potential context, if any
        context = path_parts[0].respond_to?(:to_sym) ? 
          path_parts[0].to_sym : :context_not_found
        if(orange.options[:contexts].include?(context))
          packet[:context] = path_parts.shift.to_sym
        else
          packet[:context] = orange.options[:default_context]
        end

        # Extract potential resource
        resource = path_parts[0].respond_to?(:to_sym) ? 
          path_parts[0].to_sym : :resource_not_found
        if(orange[resource] && orange[resource].routable)
          packet[:path_resource] = path_parts.shift.to_sym
        else
          packet[:path_resource] = orange.options[:default_resource]
        end

        remaining = path_parts.join('/')
        packet[:resource_path] = remaining
      end
      orange.register(:enroute, 99) do |packet|
        temp = template(packet)
        if(temp)
          packet.wrap_in(temp)
        end
      end
    end
    
    def template(packet)
      if packet[:context] == :admin
        packet.add_css('admin.css')
        packet.add_js('admin.js')
        orange.fire(:view_admin, packet)
        return 'admin.haml'
      else 
        return false
      end
    end
    
    def route_to(packet, resource, *args)
      context = packet[:context, nil]
      site = packet[:site_url, nil]
      args.unshift(resource)
      args.unshift(context)
      args.unshift(site)
      '/'+args.compact.join('/')
    end
  end
  
  module Packet_Router
    def route
      resource = packet[:path_resource]
      orange[resource].route(packet[:resource_path], packet)
    end
    
    def route_to(resource, *args)
      orange[:orange_router].route_to(self, resource, *args)
    end
    
    def reroute(url, type = :real)
      packet[:reroute_to] = url
      packet[:reroute_type] = type
      raise Reroute.new(self), 'Unhandled reroute'
    end
    
    def wrap_in(template)
      packet[:content] = orange[:parser].haml('admin.haml', packet, :wrapped_content => packet[:content], :template => true)
    end
  end
  
  class Reroute < Exception
    def initialize(packet)
      @packet = packet
      @packet[:headers] = {"Content-Type" => 'text/html', "Location" => self.url}
      @packet[:status] = 302
    end
    
    def url
      case packet[:reroute_type]
      when :real
        packet[:reroute_to]
      # Parsing for orange urls or something
      when :orange
        packet.route_to(packet[:reroute_to])
      end
    end
    
    def packet
      @packet
    end
  end
  
  class RoutableResource < Resource
    def routable; true; end
    def route(path, packet)
      parts = path.split('/')
      first = parts[0].respond_to?(:to_sym) ? parts.shift.to_sym : :index
      new_path = parts.join('/')
      if self.respond_to?(first)
        packet[:content] = self.__send__(first, new_path, packet)
      end
    end
  end
  
  class NotFoundHandler < RoutableResource
    def route(path, packet)
      packet[:content] = orange[:parser].haml('404.haml', packet)
      packet[:status] = 404
    end
  end
end