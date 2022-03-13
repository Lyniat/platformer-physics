class Arrow < Projectile

  SIZE = 50
  ANGLE_OFFSET = -45
  INITIAL_SPEED = 15
  LIFE_TIME = 3 * 60

  def initialize(x, y, x_speed, y_speed)
    @drawable = Sprite.new(SIZE,SIZE, '/sprites/arrow_flame.png', 0, 8, 8)
    super(x, y, x_speed * INITIAL_SPEED, y_speed * INITIAL_SPEED,SIZE, SIZE, @drawable)
    @has_hit = false
    @last_angle = 0
    @life_time = LIFE_TIME
  end

  def simulate(args)
    super(args)

    if @has_hit
      @life_time -= 1
      destroy if @life_time <= 0
    else
      angle = Math.atan2(y_speed, x_speed)
      degrees = 180 * angle / 3.14
      degrees = (degrees + 360 + ANGLE_OFFSET) % 360

      @drawable.angle = degrees
      @last_angle = degrees
    end
  end

  def on_hit
    super
    @has_hit = true
  end
end
