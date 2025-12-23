class Grid
  attr_reader :x, :y, :cell_w, :cell_h, :cells_x, :cells_y, :grid_w, :grid_h, :data

  def initialize(x, y, cell_w, cell_h, cells_x, cells_y, data)
    @x = x
    @y = y
    @cell_w = cell_w
    @cell_h = cell_h
    @cells_x = cells_x
    @cells_y = cells_y
    @data = data
    @grid_w = cell_w * cells_x
    @grid_h = cell_h * cells_y
    @riders = []
  end

  def simulate(physics)
    @riders.clear
  end

  def add_rider(actor)
    @riders << actor
  end
end