class Sprite < Drawable
  attr_accessor :flip, :active, :angle, :offset_x, :offset_y
  def initialize(w, h, path, start_x, spr_w, spr_h, scale_x = 1, scale_y = 1)
    super(w, h)
    @path = path
    @start_x = start_x
    @spr_w = spr_w
    @spr_h = spr_h
    @scale_x = scale_x
    @scale_y = scale_y
    @offset_x = 0
    @offset_y = 0
    @flip = false
    @active = false
    @angle = 0
  end

  def draw(tick_count,x, y)
    $args.outputs.sprites << {
      x: x - cam_x - @scale_x / 2 + offset_x,
      y: y - cam_y + offset_y,
      w: @w * @scale_x,
      h: @h * @scale_y,
      path: @path,
      source_x: @start_x * @spr_w,
      source_y: 0,
      source_w: @spr_w,
      source_h: @spr_h,
      flip_horizontally: @flip,
      angle: @angle }
  end
end
