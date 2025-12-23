class Solid
  attr_reader :x, :y, :w, :h

  def initialize(start_x, start_y, end_x, end_y, w, h, speed)
    @x = x
    @y = y
    @start_x = x
    @start_y = y 
    @end_x = end_x
    @end_y = end_y
    @w = w
    @h = h
    @x_remainder = 0
    @y_remainder =  0
    @riders = []
    @speed = speed
  end

  def simulate(physics)
    @riders.clear
  end

  def add_rider(actor)
    @riders << actor
  end
end