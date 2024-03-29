class Arrow < Projectile

  SIZE = 5
  ANGLE_OFFSET = -45
  INITIAL_SPEED = 2.5
  LIFE_TIME = 3

  def initialize(x, y, x_speed, y_speed)
    @drawable = Sprite.new(SIZE,SIZE, '/sprites/arrow_flame.png', 0, 0, 16, 16, 5, 5)
    super(x, y, x_speed * INITIAL_SPEED, y_speed * INITIAL_SPEED, SIZE, SIZE, @drawable)
    @has_hit = false
    @last_angle = 0
    @life_time = LIFE_TIME * 60

    # destroy independent of hitting target
    Service.new(LIFE_TIME, method(:remove), {}, false)
  end

  def remove args
    destroy
  end

  def simulate(tick_count)
    super(tick_count)

    if @has_hit
      @life_time -= 1
      destroy if @life_time <= 0
    else
      angle = Math.atan2(y_speed, x_speed)
      degrees = 180 * angle / 3.14
      degrees = (degrees + 360 + ANGLE_OFFSET) % 360

      @drawable.angle = degrees
      sin = Math.sin(angle)
      cos = Math.cos(angle)
      @drawable.offset_x = 0# -25 - cos * 25
      @drawable.offset_y = 0#-25 - sin * 25
      @last_angle = degrees
    end
  end

  def on_hit
    super
    @has_hit = true
  end
end
