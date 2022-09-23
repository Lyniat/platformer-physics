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
  ORANGE = Color.new(255, 153, 0)

  # PICO-8 colors taken from https://en.wikipedia.org/wiki/PICO-8
  P8_BLACK = BLACK
  P8_DARK_BLUE = Color.new(29, 43, 83)
  P8_DARK_MAGENTA = Color.new(126, 37, 83)
  P8_DARK_GREEN = Color.new(0, 135, 81)
  P8_BROWN = Color.new(171, 82, 54)
  P8_DARK_GRAY = Color.new(95, 87, 79)
  P8_LIGHT_GRAY = Color.new(194, 195, 199)
  P8_WHITE = Color.new(55, 241, 232)
  P8_RED = Color.new(255, 0, 77)
  P8_ORANGE = Color.new(255, 163, 0)
  P8_YELLOW = Color.new(255, 236, 39)
  P8_GREEN = Color.new(0, 228, 54)
  P8_CYAN = Color.new(41, 173, 255)
  P8_INDIGO = Color.new(131, 118, 156)
  P8_PINK = Color.new(255, 119, 168)
  P8_PEACH = Color.new(255, 204, 170)
end
