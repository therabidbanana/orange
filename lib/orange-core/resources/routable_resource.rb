require 'orange-core/resource'

module Orange
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
end