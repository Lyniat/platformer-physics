require 'app/rect.rb'

class Actor < Rect
  def initialize(x, y, w, h, color)
    super(x, y, w, h, color)
    @x_remainder = 0
    @y_remainder = 0
    @is_riding = false
    Level.instance.add_actor(self)
  end

  def simulate(args)
    @is_riding = false
    check_riding
  end

  def check_collision(plus_x, plus_y, ignore = nil)
    Level.instance.solids.each do |solid|
      next if solid == ignore
      if Rect.check_overlap(Rect.new(@x + plus_x, @y + plus_y, @w, @h, Color::WHITE),solid)
        return true
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
        on_collision_x
        break
      end
    end
  end

  def move_y(amount, ignore = nil)
    @y_remainder += amount
    move = @y_remainder.round

    return if move == 0

    @y_remainder -= move
    sign = move > 0 ? 1 : -1

    while move != 0
      if !check_collision(0, sign,ignore)
        @y += sign
        move -= sign
      else
        on_collision_y
        break
      end
    end
  end

  def check_riding
    Level.instance.solids.each do |solid|
      if Rect.check_overlap(Rect.new(@x, @y - 1, @w, @h, Color::WHITE),solid)
        solid.add_rider(self)
        @is_riding = true
      end
    end
  end

  def on_collision_x

  end

  def on_collision_y

  end

end
