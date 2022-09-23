class Camera
  attr_accessor :x, :y, :width, :height

  def initialize(x, y, w, h, bound_left, bound_right, bound_down, bound_up)
    @x = x
    @y = y
    @width = w
    @height = h
    @bound_left = bound_left
    @bound_right = bound_right
    @bound_down = bound_down
    @bound_up = bound_up
  end

  def mouse_x
    $args.inputs.mouse.x + @x
  end

  def mouse_y
    $args.inputs.mouse.y + @y
  end

  def update
    unless @bound_left.nil?
      if @x < @bound_left
        @x = @bound_left
      end
    end

    unless @bound_right.nil?
      if @x + @width > @bound_right
        @x = @bound_right - @width
      end
    end

    unless @bound_down.nil?
      if @y < @bound_down
        @y = @bound_down
      end
    end

    unless @bound_up.nil?
      if @y + @height > @bound_up
        @y = @bound_up - @height
      end
    end
  end
end
