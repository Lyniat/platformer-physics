class Player < Actor
  GRAVITY = -15 / 60
  SPEED = 0.7
  MAX_SPEED = 1.3
  CLIMBING_SPEED = SPEED / 2
  JUMP_VELOCITY = 2
  JUMP_VELOCITY_WALL = 3.8
  JUMP_TIME_TO_ACCELERATE = 0.25 * 60
  X_VELOCITY = 4
  X_VELOCITY_DECREASE = 0.2
  BOW_COOLDOWN = 1 * 60
  MAX_NEG_Y_SPEED = -2

  attr_reader :dead

  def initialize(x, y, w, h, rect)
    offset_x = -rect.x
    offset_y = -rect.y
    @anm_run = Animation.new(w, h, 3, 0.1, '/sprites/panda_sheet.png', 0, w, h, offset_x, offset_y)
    @anm_climb = Animation.new(w, h, 3, 0.1, '/sprites/panda_sheet.png', 3, w, h, offset_x, offset_y)
    @anm_slide = Animation.new(w, h, 1, 0.1, '/sprites/panda_sheet.png', 3, w, h, offset_x, offset_y)
    @rect = rect
    super(x, y, rect.w, rect.h, @anm_run)
    @y_speed = 0
    @x_speed = 0
    @facing_right = true
    @is_climbing = false
    @bow_cooldown = 0
    @dead = false
    @tick_count = 0
    @jump_started_tick = 0
    @jump_accelerating = false
    @x_velocity = 0
    @sliding_on_wall = false
  end

  def move_left
    @x_speed = -SPEED
    @sliding_on_wall = true if solid_left?
  end

  def move_right
    @x_speed = SPEED
    @sliding_on_wall = true if solid_right?
  end

  def move_up
    @y_speed = CLIMBING_SPEED if @is_climbing
  end

  def move_down
    @y_speed = -CLIMBING_SPEED if @is_climbing
  end

  def jump
    # normal jump
    unless solid_below?.nil? || @is_climbing
      @y_speed = JUMP_VELOCITY
      @jump_started_tick = @tick_count
      return
    end

    # wall jump
    # note: x_speed must be calculated before jumping
    if !solid_left?.nil? && @x_speed < 0
      @jump_started_tick =-1
      @y_speed = JUMP_VELOCITY_WALL
      @x_velocity = X_VELOCITY
    elsif !solid_right?.nil? && @x_speed > 0
      @jump_started_tick =-1
      @y_speed = JUMP_VELOCITY_WALL
      @x_velocity = -X_VELOCITY
    end
  end

  def jump_accelerate
    if @tick_count <= @jump_started_tick + JUMP_TIME_TO_ACCELERATE && solid_below?.nil?
      @jump_accelerating = true
    end
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
    @tick_count = tick_count
    @bow_cooldown -= 1

    @drawable = @anm_run
    if @is_climbing
      @drawable = @anm_climb
    elsif @sliding_on_wall
      @drawable = @anm_slide
    end

    if !@is_riding && !@is_climbing && !@jump_accelerating
      @y_speed += GRAVITY
      @y_speed = MAX_NEG_Y_SPEED if @y_speed < MAX_NEG_Y_SPEED
    end

    total_x_speed = (@x_speed + @x_velocity).clamp(-MAX_SPEED, MAX_SPEED)
    move_x(total_x_speed)
    total_y_speed = (@sliding_on_wall && @y_speed < 0) ? @y_speed / 4 : @y_speed
    move_y(total_y_speed)

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

    if @x_velocity != 0
      positive = @x_velocity > 0
      if positive
        @x_velocity -= X_VELOCITY_DECREASE
        if @x_velocity < 0
          @x_velocity = 0
        end
      else
        @x_velocity += X_VELOCITY_DECREASE
        if @x_velocity > 0
          @x_velocity = 0
        end
      end
    end

    @sliding_on_wall = false
    @jump_accelerating = false
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
