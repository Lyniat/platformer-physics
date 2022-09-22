class Player < Actor
  GRAVITY = -50 / 60
  SPEED = 3
  CLIMBING_SPEED = 1.5
  JUMP_VELOCITY = 20
  BOW_COOLDOWN = 1 * 60

  attr_reader :dead

  def initialize(x, y, w, h)
    @anm_run = Animation.new(w, h, 3, 0.1, '/sprites/panda_sheet.png', 0, 12, 16, 1.333)
    @anm_climb = Animation.new(w, h, 3, 0.1, '/sprites/panda_sheet.png', 3, 12, 16, 1.333)
    super(x, y, w, h, @anm_run)
    @y_speed = 0
    @x_speed = 0
    @facing_right = true
    @is_climbing = false
    @bow_cooldown = 0
    @dead = false
  end

  def move_left
    @x_speed = -SPEED
  end

  def move_right
    @x_speed = SPEED
  end

  def move_up
    @y_speed = CLIMBING_SPEED if @is_climbing
  end

  def move_down
    @y_speed = -CLIMBING_SPEED if @is_climbing
  end

  def jump
    @y_speed = JUMP_VELOCITY unless solid_below?.nil? || @is_climbing
  end

  def fire(at_x, at_y)
    return if @bow_cooldown > 0
    @bow_cooldown = BOW_COOLDOWN
    mid_x = x + w / 2
    mid_y = y + h / 2

    dir_x = at_x - mid_x
    dir_y = at_y - mid_y

    highest = dir_x.abs > dir_y.abs ? dir_x.abs : dir_y.abs

    dir_x /= highest
    dir_y /= highest

    Arrow.new(mid_x, mid_y, dir_x, dir_y)
  end

  def climb
    solid = nil
    solid = solid_right? if @facing_right
    solid = solid_left? unless @facing_right

    unless solid == nil
      solid.add_rider(self)
      @is_riding = true
      @is_climbing = true
      @y_speed = 0
    end
  end

  def simulate(tick_count)
    @bow_cooldown -= 1

    if @is_climbing
      @drawable = @anm_climb
    else
      @drawable = @anm_run
    end

    if !@is_riding && !@is_climbing
      @y_speed += GRAVITY
    end

    move_x(@x_speed)
    move_y(@y_speed)

    if @drawable.respond_to? :flip=
      if @x_speed > 0
        @drawable.flip = false
        @facing_right = true
      end
      if @x_speed < 0
        @drawable.flip = true
        @facing_right = false
      end
    end

    if @drawable.respond_to? :active=
      @drawable.active = @x_speed != 0 || (@is_climbing && @y_speed != 0)
    end

    super(tick_count)

    @x_speed = 0
    @is_riding = false

  end

  def draw(tick_count)
    @is_climbing = false
    super
  end

  def on_collision_y(squish)
    if squish
      @dead = true
      destroy
    end
    @y_speed = 0
    super
  end

  def on_collision_x(squish)
    if squish
      @dead = true
      destroy
    end
    super
  end
end
