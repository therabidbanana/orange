module Orange
  class Router < Resource
    def route(context)
      return orange[:parser].haml('index.haml', context)
    end
  end
end