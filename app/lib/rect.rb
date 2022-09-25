class Rect
  attr_accessor :x, :y
  attr_reader :w, :h

  def initialize(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def get_right
    @x + @w
  end

  def get_left
    @x
  end

  def get_up
    @y + @h
  end

  def get_down
    @y
  end

  def get_center_h
    @x + @w
  end

  def get_center_v
    @y + @h
  end

  def get_center
    return get_center_h, get_center_v
  end

  def self.check_overlap(rect1, rect2)
    rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
  end

  def debug_draw(tick_count, color)
    camera = Level.instance.camera

    x = @x * camera.x_factor + camera.rel_x
    y = @y * camera.y_factor + camera.rel_y
    w = @w * camera.x_factor
    h = @h * camera.y_factor
    cam_x = camera.x * camera.x_factor
    cam_y = camera.y * camera.y_factor
    $args.outputs.lines  << [x - cam_x, y - cam_y, x - cam_x, y - cam_y + h, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [x - cam_x + w, y - cam_y, x - cam_x + w, y - cam_y + h, color.r, color.g, color.b, color.a]

    $args.outputs.lines  << [x - cam_x, y - cam_y, x - cam_x + w, y - cam_y, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [x - cam_x, y - cam_y + h, x - cam_x + w, y - cam_y + h, color.r, color.g, color.b, color.a]

    $args.outputs.lines  << [x - cam_x, y - cam_y, x - cam_x + w, y - cam_y + h, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [x - cam_x + w, y - cam_y, x - cam_x, y - cam_y + h, color.r, color.g, color.b, color.a]
  end
end
