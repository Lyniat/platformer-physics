class Actor < Rect
  def initialize(x, y, w, h, drawable)
    super(x, y, w, h)
    @x_remainder = 0
    @y_remainder = 0
    @is_riding = false
    @drawable = drawable
    Level.instance.add_actor(self)
  end

  def draw(tick_count)
    @drawable.draw(tick_count, @x, @y)
  end

  def simulate(tick_count)
    @is_riding = false
    check_riding
  end

  def check_collision(plus_x, plus_y, ignore = nil)
    Level.instance.solids.each do |solid|
      next if solid == ignore
      # first check distance for performance increase
      next unless check_distance(solid)
      if Rect.check_overlap({x: @x + plus_x, y: @y + plus_y, w: @w, h: @h}, solid)
        return true
      end
    end

    Level.instance.maps.find do |map|
      solids = map.get_solids_at(@x, @y, plus_x, plus_y)
      solids.each do |solid|
        return true if Rect.check_overlap({x: @x + plus_x, y: @y + plus_y, w: @w, h: @h}, solid)
      end
    end
    return false
  end

  def move_x(amount, ignore = nil)
    @x_remainder += amount
    move = @x_remainder.round

    return if move == 0

    @x_remainder -= move
    sign = move > 0 ? 1 : -1

    while move != 0
      if !check_collision(sign, 0,ignore)
        @x += sign
        move -= sign
      else
        on_collision_x(ignore != nil)
        break
      end
    end
  end

  def move_y(amount, ignore = nil)
    @y_remainder += amount
    move = @y_remainder.floor #changing round to floor fixes A LOT of problems (even if not sure why)

    return if move == 0

    @y_remainder -= move
    sign = move > 0 ? 1 : -1

    while move != 0
      if !check_collision(0, sign,ignore)
        @y += sign
        move -= sign
      else
        on_collision_y(ignore != nil)
        break
      end
    end
  end

  def check_riding
    solid = solid_below?
    unless solid.nil?
      solid.add_rider(self)
      @is_riding = true
    end
  end

  def solid_below?
    Level.instance.solids.find do |solid|
      next unless check_distance(solid)
      return solid if Rect.check_overlap({x: @x, y: @y - 1, w: @w, h: @h}, solid)
    end

    Level.instance.maps.find do |map|
      solids = map.get_solids_at(@x, @y, 0, -1)
      solids.find do |solid|
        return map if Rect.check_overlap({x: @x, y: @y - 1, w: @w, h: @h}, solid)
      end
    end
    return nil
  end

  def solid_above?
    Level.instance.solids.find do |solid|
      next unless check_distance(solid)
      return solid if Rect.check_overlap({x: @x, y: @y + 1, w: @w, h: @h}, solid)
    end

    Level.instance.maps.find do |map|
      solids = map.get_solids_at(@x, @y, 0, 1)
      solids.find do |solid|
        return map if Rect.check_overlap({x: @x, y: @y + 1, w: @w, h: @h}, solid)
      end
    end
    return nil
  end

  def solid_right?
    Level.instance.solids.find do |solid|
      next unless check_distance(solid)
      return solid if Rect.check_overlap({x: @x + 1, y: @y , w: @w, h: @h}, solid)
    end

    Level.instance.maps.find do |map|
      solids = map.get_solids_at(@x, @y, 1, 0)
      solids.find do |solid|
        return map if Rect.check_overlap({x: @x + 1, y: @y, w: @w, h: @h}, solid)
      end
    end
    return nil
  end

  def solid_left?
    Level.instance.solids.find do |solid|
      next unless check_distance(solid)
      return solid if Rect.check_overlap({x: @x - 1, y: @y , w: @w, h: @h}, solid)
    end

    Level.instance.maps.find do |map|
      solids = map.get_solids_at(@x, @y, -1, 0)
      solids.find do |solid|
        return map if Rect.check_overlap({x: @x - 1, y: @y, w: @w, h: @h}, solid)
      end
    end
    return nil
  end

  def on_collision_x(squish)

  end

  def on_collision_y(squish)

  end

  def check_distance(solid)
    c_x, c_y = get_center
    s_x, s_y = solid.get_center
    return false if (c_x - s_x).abs + (c_y - s_y).abs > Level.instance.physics_distance
    true
  end

  def destroy
    Level.instance.remove_actor(self)
  end

  def debug_draw(tick_count)
    super(tick_count, Color::GREEN)
  end

end
