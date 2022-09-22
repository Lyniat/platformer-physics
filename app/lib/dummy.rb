class Dummy

  attr_accessor :x, :y
  attr_reader :w, :h
  def initialize(x, y, w, h, drawable)
    @x = x
    @y = y
    @w = w
    @h = h
    @drawable = drawable
    Level.instance.add_dummy(self)
  end

  def draw(tick_count)
    @drawable.draw(tick_count, @x, @y)
  end

  def destroy
    Level.instance.remove_solid(self)
  end

end

