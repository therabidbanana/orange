class MockOrangeBasedMiddleware < Orange::Middleware::Base
  def packet_call(packet)
    raise "It's over 9000 #{@core.class.to_s}s!"
  end
end

class MockMiddleware 
  def initialize(app)
  end
  def call(env)
    raise "I'm in ur #{env[:test]}"
  end
end