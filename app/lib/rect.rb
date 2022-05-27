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
    @x + @w / 2
  end

  def get_center_v
    @y + @h / 2
  end

  def self.check_overlap(rect1, rect2)
    rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x && rect1.y < rect2.y + rect2.h && rect1.h + rect1.y > rect2.y
  end

  def debug_draw(tick_count, color)
    camera = Level.instance.camera
    cam_x = camera.nil? ? 0 : camera.x
    cam_y = camera.nil? ? 0 : camera.y
    $args.outputs.lines  << [@x - cam_x, @y - cam_y, @x - cam_x, @y - cam_y + @h, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [@x - cam_x + @w, @y - cam_y, @x - cam_x + @w, @y - cam_y + @h, color.r, color.g, color.b, color.a]

    $args.outputs.lines  << [@x - cam_x, @y - cam_y, @x - cam_x + @w, @y - cam_y, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [@x - cam_x, @y - cam_y + @h, @x - cam_x + @w, @y - cam_y + @h, color.r, color.g, color.b, color.a]

    $args.outputs.lines  << [@x - cam_x, @y - cam_y, @x - cam_x + @w, @y - cam_y + @h, color.r, color.g, color.b, color.a]
    $args.outputs.lines  << [@x - cam_x + @w, @y - cam_y, @x - cam_x, @y - cam_y + @h, color.r, color.g, color.b, color.a]
  end
end
