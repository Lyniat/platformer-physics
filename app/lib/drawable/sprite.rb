class Sprite < Drawable
  attr_accessor :flip, :active, :angle, :offset_x, :offset_y
  def initialize(w, h, path, start_x, start_y, spr_w, spr_h, offset_x = 0, offset_y = 0)
    super(w, h)
    @path = path
    @start_x = start_x
    @start_y = start_y
    @spr_w = spr_w
    @spr_h = spr_h
    @offset_x = offset_x
    @offset_y = offset_y
    @flip = false
    @active = false
    @angle = 0
  end

  def draw(tick_count,x, y)
    $args.render_target(:camera_main).sprites << {
      x: (x - cam_x + @offset_x),
      y: (y - cam_y + @offset_y),
      w: @w,
      h: @h,
      path: @path,
      source_x: @start_x * @spr_w,
      source_y: @start_y * @spr_h,
      source_w: @spr_w,
      source_h: @spr_h,
      flip_horizontally: @flip,
      angle: @angle }
  end
end
