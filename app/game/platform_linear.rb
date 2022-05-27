class PlatformLinear < Platform
  def initialize(x, y, w, h,speed, drawable, target_x, target_y)
    @target_x = target_x
    @target_y = target_y
    super(x, y, w, h, speed, drawable)
  end

  def calculate_platform(tick_count)
    progress = (Math.sin(tick_count * @speed) + 1) / 2
    x = mix(@start_x, @target_x, progress)
    y = mix(@start_y, @target_y, progress)
    move_platform(x, y)
  end
end
