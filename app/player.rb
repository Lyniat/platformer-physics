class Player < Actor
  GRAVITY = -16 / 60
  SPEED = 3
  JUMP_VELOCITY = 13

  def initialize(x, y, w, h, color)
    super(x, y, w, h, color)
    @y_speed = 0
    @x_speed = 0
  end

  def move_left
    @x_speed = -SPEED
  end

  def move_right
    @x_speed = SPEED
  end

  def jump
    @y_speed = JUMP_VELOCITY
  end

  def simulate(args)
    @y_speed += GRAVITY if !@is_riding

    move_x(@x_speed)
    move_y(@y_speed)

    super(args)

    @x_speed = 0
  end

  def on_collision_y
    @y_speed = 0
    super
  end
end
