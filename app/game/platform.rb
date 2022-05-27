class Platform < Solid
  def initialize(x, y, w, h,speed, drawable)
    @start_x = x
    @start_y = y
    @speed = speed
    @last_x = @start_x
    @last_y = @start_y
    super(x, y, w, h, drawable)
  end

  def calculate_platform(tick_count)

  end

  def move_platform(x,y)
    move(x - @last_x, y - @last_y)
    @last_x = x
    @last_y = y
  end

  def get_progress(tick_count)
    (Math.sin(tick_count * @speed) + 1) / 2
  end

  def mix(x, y, a)
    x * (1 - a) + y * a
  end

  def simulate(tick_count)
    calculate_platform(tick_count)
    super(tick_count)
  end
end
