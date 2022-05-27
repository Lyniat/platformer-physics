class Camera
  attr_accessor :x, :y

  WIDTH = 1280
  HEIGHT = 720
  def initialize(tick_count, x, y)
    @x = x
    @y = y
  end

  def mouse_x
    $args.inputs.mouse.x + @x
  end

  def mouse_y
    $args.inputs.mouse.y + @y
  end

  def update

  end
end
