class Box < Drawable
  def initialize(w, h, color = Color::BLACK)
    @color = color
    super(w,h)
  end

  def draw(args, x, y)
    args.outputs.solids << [x - cam_x, y - cam_y, @w, @h, @color.r, @color.g, @color.b, @color.a]
    super(args)
  end
end
