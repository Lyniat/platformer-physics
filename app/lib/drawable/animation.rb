class Animation < Drawable
  attr_accessor :flip, :active
  def initialize(w, h, frames, speed, path, start_x, spr_w, spr_h, scale_x = 1, scale_y = 1)
    super(w, h)
    @speed = speed
    @frames = frames
    @path = path
    @start_x = start_x
    @spr_w = spr_w
    @spr_h = spr_h
    @scale_x = scale_x
    @scale_y = scale_y
    @flip = false
    @active = false
  end

  def draw(tick_count,x, y)
    current_pos = (@active ? (tick_count * @speed).to_i : 0) % @frames
    $args.outputs.sprites << {
                               x: x - cam_x - @scale_x / 2,
                               y: y - cam_y,
                               w: @w * @scale_x,
                               h: @h * @scale_y,
                               path: @path,
                               source_x: @start_x * @spr_w + current_pos * @spr_w,
                               source_y: 0,
                               source_w: @spr_w,
                               source_h: @spr_h,
                               flip_horizontally: @flip}
  end

end
