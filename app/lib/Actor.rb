class Actor
  attr_reader :x, :y, :w, :h, :is_riding

  def initialize(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
    @is_riding = false
    @x_remainder = 0
    @y_remainder = 0
  end

  def simulate (physics)
    @is_riding = false
    check_riding(physics)
  end

  def check_riding(physics)
    solid = get_solid_below(physics)
    unless solid.nil?
        solid.add_rider(self)
        @is_riding = true
    end
  end

  def get_solid_below(physics)
    solids = physics.solids
    solids.each do |solid|
        # return solid if check_overlap({x: @x, y: @y - 1, w: @w, h: @h}, {x: solid.x, y: solid.y, w: solid.w, h: solid.h})
        return solid if physics.check_overlap({x: @x, y: @y - 1, w: @w, h: @h}, solid)
    end
    grids = physics.grids
    grids.each do |grid|
        grid_overlap = physics.check_overlap_grid({x: @x, y: @y - 1, w: @w, h: @h}, grid)
        return grid_overlap unless grid_overlap.nil?
    end
    return nil
  end

  def move_x(physics, amount, ignore = nil)
  if amount == 0
    #return
  end

  @x_remainder += amount
  move = @x_remainder.round

  #puts "move: #{move}, remainder: #{x_remainder}"
  if move == 0
    return
  end

  # see (*1)
  sign = move > 0 ? 1 : -1
  sign_amount = amount > 0 ? 1 : -1
  if sign != sign_amount
    return
  end

  @x_remainder -= move

  while move != 0
    solid = check_collision(physics, sign, 0, ignore)
    if solid.nil?
      solid = check_collision_grid(physics, sign, 0)
    end
    if solid.nil?
      @x += sign
      move -= sign
    else
        return solid
      #should_break = true

      #on_collision_actor = actor.on_collision_x
      #on_collision_solid = solid.on_collision_x

      #should_break = method(on_collision_actor).call(actor, solid, ignore != nil) unless on_collision_actor.nil?
      #method(on_collision_solid).call(actor, solid, ignore != nil) unless on_collision_solid.nil?

      #break unless should_break == false

      #@x += sign
      #move -= sign
    end
  end
end

def move_y(physics, amount, ignore = nil)
  if amount == 0
    return
  end

  @y_remainder += amount
  move = @y_remainder.floor # changing round to floor fixes A LOT of problems (even if not sure why)

  if move == 0
    return
  end

  # see (*1)
  sign = move > 0 ? 1 : -1
  sign_amount = amount > 0 ? 1 : -1
  if sign != sign_amount
    return
  end

  @y_remainder -= move

  while move != 0
    solid = check_collision(physics, 0, sign, ignore)
    if solid.nil?
      solid = check_collision_grid(physics, 0, sign)
    end
    if solid.nil?
      @y += sign
      move -= sign
    else
      return solid
      #should_break = true

      #on_collision_actor = actor.on_collision_y
      #on_collision_solid = solid.on_collision_y

      #should_break = method(on_collision_actor).call(actor, solid, ignore != nil) unless on_collision_actor.nil?
      #method(on_collision_solid).call(actor, solid, ignore != nil) unless on_collision_solid.nil?

      #break unless should_break == false

      #@y += sign
      #move -= sign
    end
  end
end

def check_collision_grid(physics, plus_x, plus_y, ignore = nil)
    grids = physics.grids
    grids.each do |grid|
        if physics.check_overlap_grid({x: @x + plus_x, y: @y + plus_y, w: @w, h: @h}, grid)
            return grid
        end
    end
    return nil
end

def check_collision(physics, plus_x, plus_y, ignore = nil)
    solids = physics.solids
    solids.each do |solid|
        next if solid == false
        if physics.check_overlap({x: @x + plus_x, y: @y + plus_y, w: @w, h: @h}, solid)
            return solid
        end
    end
    return nil
end
end