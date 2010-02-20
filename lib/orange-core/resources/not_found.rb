require 'orange-core/resource'
module Orange
  class NotFound < Orange::Resource
    call_me :not_found
    def route(packet)
      packet[:content] = orange[:parser].haml("404.haml", packet, :resource => self)
      packet[:status] = 404
    end
  end
end