class Drawable
  def initialize(w, h)
    @w = w
    @h = h
  end

  def draw(args)

  end

  def cam_x
    camera = Level.instance.camera
    camera.nil? ? 0 : camera.x
  end

  def cam_y
    camera = Level.instance.camera
    camera.nil? ? 0 : camera.y
  end
end
