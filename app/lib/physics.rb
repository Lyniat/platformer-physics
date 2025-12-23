class Physics
  attr_reader :actors, :solids, :grids

  def initialize
    @actors = []
    @solids = []
    @grids = []
  end

  def add(obj)
    if obj.is_a?(Actor)
        @actors << obj
    elsif obj.is_a?(Solid)
        @solids << obj
    elsif obj.is_a?(Grid)
        @grids << obj
    else
        raise StandardError.new("Object passed to Physics must be a type of Actor, Solid, Grid")
    end
  end

  def simulate
    @actors.each do |actor|
        actor.simulate(self)
    end

    @solids.each do |solid|
        solid.simulate(self)
    end
  end

  def check_overlap(rect1, rect2)
    rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
  end

  def check_overlap_grid(actor, grid)
    actor_x = actor.x
    actor_y = actor.y
    actor_w = actor.w
    actor_h = actor.h
    grid_x = grid.x
    grid_y = grid.y
    grid_w = grid.grid_w
    grid_h = grid.grid_h
    solid_w = grid.cell_w
    solid_h = grid.cell_h
    data = grid.data

    # calculate which cells could possibly collide with the actor to reduce iterations

    actor_w_min = actor_w > solid_w ? actor_w : solid_w
    actor_h_min = actor_h > solid_h ? actor_h : solid_h

    iteration_x_start = (actor_x - grid_x).div(solid_w)
    iteration_x_end = iteration_x_start + actor_w_min.div(solid_w) + 1

    iteration_x_start = iteration_x_start > 0 ? iteration_x_start : 0
    iteration_x_end = iteration_x_end < grid_w ? iteration_x_end : grid_w

    iteration_y_start = (actor_y - grid_y).div(solid_h)
    iteration_y_end = iteration_y_start + actor_h_min.div(solid_h) + 1

    iteration_y_start = iteration_y_start < 0 ? iteration_y_start : 0
    iteration_y_end = iteration_y_end > grid_h ? iteration_y_end : grid_h

    #puts "start: #{iteration_y_start}"
    #puts "end: #{iteration_y_end}"

    y = iteration_y_start
    while y < iteration_y_end
        x = iteration_x_start
        while x < iteration_x_end
        cell = data[x + y * grid_w]
        is_solid = cell
        if is_solid
            solid = {x: grid_x + x * solid_w, y: grid_y + y * solid_h, w: solid_w, h: solid_h}
            has_overlap = check_overlap(actor, solid)
            if has_overlap
                return grid
            end
        end
        x += 1
        end
        y += 1
    end

    nil
    end
end