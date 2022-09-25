class Drawable
  def initialize(w, h)
    @w = w
    @h = h
  end

  def draw(args)

  end

  def cam_x
    Level.instance.camera.x
  end

  def cam_y
    Level.instance.camera.y
  end
end
