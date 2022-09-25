class Animation < Drawable
  attr_accessor :flip, :active
  def initialize(w, h, frames, speed, path, start_x, spr_w, spr_h, offset_x = 0, offset_y = 0)
    super(w, h)
    @speed = speed
    @frames = frames
    @path = path
    @start_x = start_x
    @spr_w = spr_w
    @spr_h = spr_h
    @offset_x = offset_x
    @offset_y = offset_y
    @flip = false
    @active = false
  end

  def draw(tick_count,x, y)
    current_pos = (@active ? (tick_count * @speed).to_i : 0) % @frames
    $args.render_target(:camera_main).sprites << {
                               x: x - cam_x + @offset_x,
                               y: y - cam_y + @offset_y,
                               w: @w,
                               h: @h,
                               path: @path,
                               source_x: @start_x * @spr_w + current_pos * @spr_w,
                               source_y: 0,
                               source_w: @spr_w,
                               source_h: @spr_h,
                               flip_horizontally: @flip}
  end
end
