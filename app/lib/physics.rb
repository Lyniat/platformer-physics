# MISC
def check_overlap(rect1, rect2)
  rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
end

# ACTOR PART
def actor_simulate(actor, solids)
  actor.is_riding = false
  actor_check_riding(actor, solids)
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

def actor_move_x(actor, solids, amount, ignore = nil)
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

def actor_move_y(actor, solids, amount, ignore = nil)
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

def actor_check_riding(actor, solids)
  solid = actor_get_solid_below(actor, solids)
  unless solid.nil?
    solid_add_rider(solid, actor)
    actor.is_riding = true
  end
end

def actor_get_solid_below(actor, solids)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x, y: actor.y - 1, w: actor.w, h: actor.h}, solid)
  end

  return nil
end

def actor_get_solid_above(actor, solids)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x, y: actor.y + 1, w: actor.w, h: actor.h}, solid)
  end

  return nil
end

def actor_get_solid_right(actor, solids)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x + 1, y: actor.y , w: actor.w, h: actor.h}, solid)
  end

  return nil
end

def actor_get_solid_left(actor, solids)
  solids.each do |solid|
    return solid if check_overlap({x: actor.x - 1, y: actor.y , w: actor.w, h: actor.h}, solid)
  end

  return nil
end

# SOLID PART

def solid_simulate(solid)
  solid.riders.clear
end

def solid_add_rider(solid, actor)
  solid.riders << actor unless solid.riders.include?(actor)
end

def solid_move(solid, actors, solids, x, y)
  solid_move_x(solid, actors, solids, x)
  solid_move_y(solid, actors, solids, y)
  return
  x_remainder = solid.x_remainder
  y_remainder = solid.y_remainder

  x_remainder += x
  y_remainder += y

  own_x = solid.x
  own_y = solid.y

  move_x = x_remainder.round
  move_y = y_remainder.round

  if move_x == 0 && move_y == 0
    solid.x_remainder = x_remainder
    solid.y_remainder = y_remainder
    return
  end

  # x movement
  if move_x != 0
    x_remainder -= move_x
    own_x += move_x
    solid.x = own_x

    if move_x > 0
      actors.each do |actor|
        if check_overlap(actor, solid)
          amount = solid.x + solid.w - actor.x
          actor_move_x(actor, solids, amount, solid)
        elsif solid.riders.include? actor
          actor_move_x(actor, solids, move_x)
        end
      end
    else
      actors.each do |actor|
        if check_overlap(actor, solid)
          amount = solid.x - (actor.x + actor.w)
          actor_move_x(actor, solids, amount, solid)
        elsif solid.riders.include? actor
          actor_move_x(actor, solids, move_x)
        end
      end
    end
  end

  # y movement
  if move_y != 0
    y_remainder -= move_y
    own_y += move_y
    solid.y = own_y

    if move_y > 0
      actors.each do |actor|
        if check_overlap(actor, solid)
          amount = solid.y + solid.h - actor.y
          actor_move_y(actor, solids, amount, solid)
        elsif solid.riders.include? actor
          actor_move_y(actor, solids, move_y)
        end
      end
    else
      actors.each do |actor|
        if check_overlap(actor, solid)
          amount = solid.y - (actor.y + actor.h)
          actor_move_y(actor, solids, amount, solid)
        elsif solid.riders.include? actor
          actor_move_y(actor, solids, move_y)
        end
      end
    end
  end

  solid.x_remainder = x_remainder
  solid.y_remainder = y_remainder
end

def solid_move_x(solid, actors, solids, x)
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
        actor_move_x(actor, solids, amount, solid)
      elsif solid.riders.include? actor
        actor_move_x(actor, solids, move_x)
      end
    end
  else
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.x - (actor.x + actor.w)
        actor_move_x(actor, solids, amount, solid)
      elsif solid.riders.include? actor
        actor_move_x(actor, solids, move_x)
      end
    end
  end

  solid.x_remainder = x_remainder
end

def solid_move_y(solid, actors, solids, y)
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
        actor_move_y(actor, solids, amount, solid)
      elsif solid.riders.include? actor
        actor_move_y(actor, solids, move_y)
      end
    end
  else
    actors.each do |actor|
      if check_overlap(actor, solid)
        amount = solid.y - (actor.y + actor.h)
        actor_move_y(actor, solids, amount, solid)
      elsif solid.riders.include? actor
        actor_move_y(actor, solids, move_y)
      end
    end
  end

  solid.y_remainder = y_remainder
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
