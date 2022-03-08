class Rect
  attr_accessor :x, :y
  attr_reader :w, :h

  def initialize(x, y, w, h, color)
    @x = x
    @y = y
    @w = w
    @h = h
    @color = color
  end

  def draw(args)
    args.outputs.solids << [@x, @y, @w, @h, @color.r, @color.g, @color.b, @color.a]
  end

  def get_right
    @x + @w
  end

  def get_left
    @x
  end

  def get_up
    @y + @h
  end

  def get_down
    @y
  end

  def self.check_overlap(rect1, rect2)
    rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
  end
end
