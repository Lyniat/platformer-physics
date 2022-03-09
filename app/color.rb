class Color
  attr_reader :r, :g, :b, :a

  def initialize(r, g, b, a = 255)
    @r = r
    @g = g
    @b = b
    @a = a
  end

  WHITE = Color.new(255, 255, 255)
  RED = Color.new(255, 0, 0)
  BLUE = Color.new(0, 0, 255)
  GREEN = Color.new(0, 255, 0)
  BLACK = Color.new(0, 0, 0)
  YELLOW = Color.new(255, 255, 0)
end
