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

class MockOrangeBasedMiddlewareTwo < Orange::Middleware::Base; end
class MockOrangeBasedMiddlewareThree < Orange::Middleware::Base
  def stack_init
  end
end
class MockOrangeDeathMiddleware < Orange::Middleware::Base
  def init(*args)
    opts = args.extract_options!
    raise "middleware_init with foo=#{opts[:foo]}"
  end
end