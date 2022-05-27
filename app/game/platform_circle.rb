class PlatformCircle < Platform
  def initialize(x, y, w, h,speed, drawable, rad)
    @rad = rad
    super(x, y, w, h, speed, drawable)
  end

  def calculate_platform(tick_count)
    progress = tick_count * @speed
    x = Math.sin(progress) * @rad + @start_x
    y = Math.cos(progress) * @rad + @start_y
    move_platform(x, y)
  end
end

