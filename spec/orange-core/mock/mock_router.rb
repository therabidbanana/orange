
class TestRouter
  attr_accessor :x
  def initialize
   @x = 0
  end
  def route(packet)
    @x += 1
  end
end