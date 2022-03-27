class Projectile < Actor
  attr_reader :x_speed, :y_speed

  GRAVITY = -16 / 60

  def initialize(x, y, x_speed, y_speed, w, h, drawable)
    super(x, y, w, h, drawable)
    @x_speed = x_speed
    @y_speed = y_speed
  end

  def simulate(args)
    @y_speed += GRAVITY unless @is_riding
    move_x(@x_speed)
    move_y(@y_speed)

    solid = nil
    possible_solids = []
    possible_solids << solid_right?
    possible_solids << solid_left?
    possible_solids << solid_below?
    possible_solids << solid_above?

    possible_solids.each do |ps|
      next if ps == nil
      solid = ps
    end

    unless solid == nil
      solid.add_rider(self)
      @is_riding = true
    end
  end

  def on_hit
    @x_speed = 0
    @y_speed = 0
  end

  def on_collision_x(squish)
    destroy if squish
    on_hit
  end

  def on_collision_y(squish)
    destroy if squish
    on_hit
  end
end