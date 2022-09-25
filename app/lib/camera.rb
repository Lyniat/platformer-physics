class Camera

  SCREEN_RATIO = 1280 / 720

  attr_accessor :x, :y, :width, :height, :rel_width, :rel_height, :x_factor, :y_factor, :rel_x, :rel_y

  def initialize(x, y, w, h, bound_left, bound_right, bound_down, bound_up)
    @x = x
    @y = y
    @width = w
    @height = h
    @rel_width = @width
    @rel_height = @height
    @x_factor = 1
    @y_factor = 1
    @rel_x = 0
    @rel_y = 0
    @bound_left = bound_left
    @bound_right = bound_right
    @bound_down = bound_down
    @bound_up = bound_up
    calculate_rel_values
  end

  def mouse_x
    ($args.inputs.mouse.x - @rel_x) / x_factor
  end

  def mouse_y
    ($args.inputs.mouse.y - @rel_y) / y_factor
  end

  def update
    calculate_rel_values

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

  def calculate_rel_values
    ratio = @width / @height
    if ratio > SCREEN_RATIO
      r = 1280 / @width
      @rel_width = 1280
      @rel_height = @height * r
    else
      r = 720 / @height
      @rel_width = @width * r
      @rel_height = 720
    end

    @x_factor = @rel_width / @width
    @y_factor = @rel_height / @height

    @rel_x = (1280 - @rel_width) / 2
    @rel_y = (720 - @rel_height) / 2
  end
end
