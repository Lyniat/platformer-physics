class Platform < Solid
  def initialize(x, y, w, h,target_x,target_y,speed, drawable)
    @start_x = x
    @start_y = y
    @target_x = target_x
    @target_y = target_y
    @speed = speed
    @last_x = @start_x
    @last_y = @start_y
    super(x, y, w, h, drawable)
  end

  def move_platform(args)
    progress = (Math.sin(args.state.tick_count * @speed) + 1) / 2
    x = mix(@start_x, @target_x, progress)
    y = mix(@start_y, @target_y, progress)

    move(x - @last_x, y - @last_y)
    @last_x = x
    @last_y = y
  end

  def mix(x, y, a)
    x * (1 - a) + y * a
  end

  def simulate(args)
    move_platform(args)
    super(args)
  end
end
