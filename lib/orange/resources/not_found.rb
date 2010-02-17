module Orange
  class NotFound < Orange::Resource
    call_me :not_found
    def route(packet)
      packet[:content] = orange[:parser].haml("404.haml", packet, :resource => self)
    end
  end
end