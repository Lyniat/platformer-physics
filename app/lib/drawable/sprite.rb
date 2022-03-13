class Sprite < Drawable
  attr_accessor :flip, :active, :angle
  def initialize(w, h,path, start_x, spr_w, spr_h)
    super(w, h)
    @path = path
    @start_x = start_x
    @spr_w = spr_w
    @spr_h = spr_h
    @flip = false
    @active = false
    @angle = 0
  end

  def draw(args,x, y)
    args.outputs.sprites << {
      x: x - cam_x,
      y: y - cam_y,
      w: @w,
      h: @h,
      path: @path,
      source_x: @start_x * @spr_w,
      source_y: 0,
      source_w: @spr_w,
      source_h: @spr_h,
      flip_horizontally: @flip,
      angle: @angle}
  end
end
