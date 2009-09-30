module Orange
  class Router < Resource
    def route(context)
      return orange[:parser].haml('index.haml', :env => context[:env])
    end
  end
end