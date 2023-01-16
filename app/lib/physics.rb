# MISC
def check_overlap(rect1, rect2)
  rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
end

# ACTOR PART
def actor_simulate(actor, solids, grid)
  actor.is_riding = false
  actor_check_riding(actor, solids, grid)
end

def actor_check_collision(actor, solids, plus_x, plus_y, ignore = nil)
  solids.each do |solid|
    next if solid == ignore
    if check_overlap({x: actor.x + plus_x, y: actor.y + plus_y, w: actor.w, h: actor.h}, solid)
      return solid
    end
  end
  nil
end

def actor_move_x(actor, solids, grid, amount, ignore = nil)
  if amount == 0
    #return
  end
  x_remainder = actor.x_remainder
  x = actor.x

  x_remainder += amount
  move = x_remainder.round

  #puts "move: #{move}, remainder: #{x_remainder}"
  if move == 0
    actor.x_remainder = x_remainder
    return
  end

  # see (*1)
  sign = move > 0 ? 1 : -1
  sign_amount = amount > 0 ? 1 : -1
  if sign != sign_amount
    return
  end

  x_remainder -= move

  while move != 0
    solid = actor_check_collision(actor, solids, sign, 0, ignore)
    if solid.nil?
      solid = actor_check_collision_grid(actor, grid, sign, 0)
    end
    if solid.nil?
      x += sign
      actor.x = x
      move -= sign
    else
      on_collision_actor = actor.on_collision_x
      on_collision_solid = solid.on_collision_x
      method(on_collision_actor).call(actor, solid, ignore != nil) unless on_collision_actor.nil?
      method(on_collision_solid).call(actor, solid, ignore != nil) unless on_collision_solid.nil?
      break
    end
  end

  actor.x_remainder = x_remainder
end

def actor_move_y(actor, solids, grid, amount, ignore = nil)
  if amount == 0
    return
  end
  y_remainder = actor.y_remainder
  y = actor.y

  y_remainder += amount
  move = y_remainder.round #changing round to floor fixes A LOT of problems (even if not sure why)

  if move == 0
    actor.y_remainder = y_remainder
    return false
  end

  # see (*1)
  sign = move > 0 ? 1 : -1
  sign_amount = amount > 0 ? 1 : -1
  if sign != sign_amount
    return
  end

  y_remainder -= move

  while move != 0
    solid = actor_check_collision(actor, solids, 0, sign, ignore)
    if solid.nil?
      solid = actor_check_collision_grid(actor, grid, 0, sign)
    end
    if solid.nil?
      y += sign
      actor.y = y
      move -= sign
    else
      on_collision_actor = actor.on_collision_y
      on_collision_solid = solid.on_collision_y
      method(on_collision_actor).call(actor, solid, ignore != nil) unless on_collision_actor.nil?
      method(on_collision_solid).call(actor, solid, ignore != nil) unless on_collision_solid.nil?
      break
    end
  end

  actor.y_remainder = y_remainder
end

def actor_check_riding(actor, solids, grid)
  solid = actor_get_solid_below(actor, solids, grid)
  unless solid.nil?
    solid_add_rider(solid, actor)
    actor.is_riding = true
  end
end

def actor_get_solid_below(actor, solids, grid)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x, y: actor.y - 1, w: actor.w, h: actor.h}, solid)
  end
  grid_overlap = check_overlap_grid({x: actor.x, y: actor.y - 1 , w: actor.w, h: actor.h}, grid)
  return grid_overlap unless grid_overlap.nil?

  return nil
end

def actor_get_solid_above(actor, solids, grid)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x, y: actor.y + 1, w: actor.w, h: actor.h}, solid)
  end
  grid_overlap = check_overlap_grid({x: actor.x, y: actor.y + 1 , w: actor.w, h: actor.h}, grid)
  return grid_overlap unless grid_overlap.nil?

  return nil
end

def actor_get_solid_right(actor, solids, grid)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x + 1, y: actor.y , w: actor.w, h: actor.h}, solid)
  end
  grid_overlap = check_overlap_grid({x: actor.x + 1, y: actor.y , w: actor.w, h: actor.h}, grid)
  return grid_overlap unless grid_overlap.nil?

  return nil
end

def actor_get_solid_left(actor, solids, grid)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x - 1, y: actor.y , w: actor.w, h: actor.h}, solid)
  end
  grid_overlap = check_overlap_grid({x: actor.x - 1, y: actor.y , w: actor.w, h: actor.h}, grid)
  return grid_overlap unless grid_overlap.nil?

  return nil
end

# SOLID PART

def solid_simulate(solid)
  solid.riders.clear
end

def solid_add_rider(solid, actor)
  unless solid.riders.nil?
    solid.riders << actor unless solid.riders.include?(actor)
  end
end

def solid_move(solid, actors, solids, grid, x, y)
  solid_move_x(solid, actors, solids, grid, x)
  solid_move_y(solid, actors, solids, grid, y)
end

def solid_move_x(solid, actors, solids, grid, x)
  return if x == 0
  x_remainder = solid.x_remainder

  x_remainder += x

  own_x = solid.x

  move_x = x_remainder.round

  if move_x == 0
    solid.x_remainder = x_remainder
    return
  end

  # x movement
  x_remainder -= move_x
  own_x += move_x
  solid.x = own_x

  if move_x > 0
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.x + solid.w - actor.x
        actor_move_x(actor, solids, grid, amount, solid)
      elsif solid.riders.include? actor
        actor_move_x(actor, solids, grid, move_x)
      end
    end
  else
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.x - (actor.x + actor.w)
        actor_move_x(actor, solids, grid, amount, solid)
      elsif solid.riders.include? actor
        actor_move_x(actor, solids, grid, move_x)
      end
    end
  end

  solid.x_remainder = x_remainder
end

def solid_move_y(solid, actors, solids, grid, y)
  return if y == 0
  y_remainder = solid.y_remainder

  y_remainder += y

  own_y = solid.y

  move_y = y_remainder.round

  if move_y == 0
    solid.y_remainder = y_remainder
    return
  end

  # y movement
  y_remainder -= move_y
  own_y += move_y
  solid.y = own_y

  if move_y > 0
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.y + solid.h - actor.y
        actor_move_y(actor, solids, grid, amount, solid)
      elsif solid.riders.include? actor
        actor_move_y(actor, solids, grid, move_y)
      end
    end
  else
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.y - (actor.y + actor.h)
        actor_move_y(actor, solids, grid, amount, solid)
      elsif solid.riders.include? actor
        actor_move_y(actor, solids, grid, move_y)
      end
    end
  end

  solid.y_remainder = y_remainder
end

# ADDITIONAL CODE FOR GRIDS
def actor_check_collision_grid(actor, grid, plus_x, plus_y)
  return check_overlap_grid({x: actor.x + plus_x, y: actor.y + plus_y, w: actor.w, h: actor.h}, grid)
  actor_x = actor.x
  actor_y = actor.y
  actor_w = actor.w
  actor_h = actor.h
  grid_x = grid.x
  grid_y = grid.y
  grid_w = grid.w
  grid_h = grid.h
  solid_w = grid.solid_w
  solid_h = grid.solid_h
  data = grid.data

  y = 0
  while y < grid_h
    x = 0
    while x < grid_w
      cell = data[x + y * grid_w]
      is_solid = cell.is_solid
      if is_solid
        solid = {x: grid_x + x * solid_w, y: grid_y +  y * solid_h, w: solid_w, h: solid_h}
        has_overlap = check_overlap({x: actor_x + plus_x, y: actor_y + plus_y, w: actor_w, h: actor_h}, solid)
        if has_overlap
          return solid
        end
      end
      x += 1
    end
    y += 1
  end

  nil
end

def check_overlap_grid(actor, grid)
  actor_x = actor.x
  actor_y = actor.y
  actor_w = actor.w
  actor_h = actor.h
  grid_x = grid.x
  grid_y = grid.y
  grid_w = grid.w
  grid_h = grid.h
  solid_w = grid.solid_w
  solid_h = grid.solid_h
  data = grid.data

  # calculate which cells could possibly collide with the actor to reduce iterations

  iteration_x_start = (actor_x - grid_x).div(solid_w)
  iteration_x_end = iteration_x_start + actor_w.div(solid_w) + 1

  iteration_x_start = iteration_x_start > 0 ? iteration_x_start : 0
  iteration_x_end = iteration_x_end < grid_w ? iteration_x_end : grid_w

  iteration_y_start = (actor_y - grid_y).div(solid_h)
  iteration_y_end = iteration_y_start + actor_h.div(solid_h) + 1

  iteration_y_start = iteration_y_start > 0 ? iteration_y_start : 0
  iteration_y_end = iteration_y_end < grid_h ? iteration_y_end : grid_h

  y = iteration_y_start
  while y < iteration_y_end
    x = iteration_x_start
    while x < iteration_x_end
      cell = data[x + y * grid_w]
      is_solid = cell.is_solid
      if is_solid
        solid = {x: grid_x + x * solid_w, y: grid_y + y * solid_h, w: solid_w, h: solid_h}
        has_overlap = check_overlap({x: actor_x, y: actor_y, w: actor_w, h: actor_h}, solid)
        if has_overlap
          return solid
        end
      end
      x += 1
    end
    y += 1
  end

  nil
end

# NOTES
# (*1)
# this test does not exist in the original algorithm
# sometimes it might happen that the direction the actor moves is the opposite of what it actually should do
# which can lead to jitter
# this is caused by rounding the remainder
# example (the actor is at 0.5 but doesn't get any direction to move in the following frames):
# frame 1: remainder: 0.5 -> move: 1.0 (by rounding remainder) -> remainder: -0.5 (by remainder - move)
# frame 2: remainder: -0.5 -> move: -1.0 (by rounding remainder) -> remainder: 0.5 (by remainder - move)
# frame 3: remainder: 0.5 -> move: 1.0 (by rounding remainder) -> remainder: -0.5 (by remainder - move)
# and so on ...
