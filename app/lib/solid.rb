class Solid < Rect

  def initialize(x, y, w, h, drawable)
    super(x, y, w, h)
    @x_remainder = 0
    @y_remainder = 0
    @riders = []
    @drawable = drawable
    Level.instance.add_solid(self)
  end

  def draw(tick_count)
    @drawable.draw(tick_count, @x, @y)
  end

  def simulate(tick_count)
    @riders.clear
  end

  def add_rider(actor)
    @riders << actor unless @riders.include?(actor)
  end

  def move (x, y)
    @x_remainder += x
    @y_remainder += y

    move_x = @x_remainder.round
    move_y = @y_remainder.round

    return if move_x == 0 && move_y == 0

    # list riding

    @collidable = false

    # x movement
    if move_x != 0
      @x_remainder -= move_x
      @x += move_x

      if move_x > 0
        Level.instance.actors.each do |actor|
          if Rect.check_overlap(actor, self)
            actor.move_x(get_right - actor.get_left,self)
          elsif @riders.include? actor
            actor.move_x(move_x)
          end
        end
      else
        Level.instance.actors.each do |actor|
          if Rect.check_overlap(actor, self)
            actor.move_x(get_left - actor.get_right,self)
          elsif @riders.include? actor
            actor.move_x(move_x)
          end
        end
      end
    end

    # y movement
    if move_y != 0
      @y_remainder -= move_y
      @y += move_y

      if move_y > 0
        Level.instance.actors.each do |actor|
          if Rect.check_overlap(actor, self)
            actor.move_y(get_up - actor.get_down,self)
          elsif @riders.include? actor
            actor.move_y(move_y)
          end
        end
      else
        Level.instance.actors.each do |actor|
          if Rect.check_overlap(actor, self)
            actor.move_y(get_down - actor.get_up,self)
          elsif @riders.include? actor
            actor.move_y(move_y)
          end
        end
      end
    end
  end

  def destroy
    Level.instance.remove_solid(self)
  end

  def debug_draw(tick_count)
    super(tick_count, Color::RED)
  end

end
