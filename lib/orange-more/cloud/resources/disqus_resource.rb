module Orange
  class DisqusResource < Orange::Resource
    call_me :disqus
    def comment_thread(packet, opts = {})
      opts.merge!(:resource => self)
      orange[:parser].haml("comment_thread.haml", packet, opts)
    end
  end
end