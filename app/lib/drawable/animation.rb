class Animation < Drawable
  attr_accessor :flip, :active
  def initialize(w, h, frames, speed, path, start_x, spr_w, spr_h)
    super(w, h)
    @speed = speed
    @frames = frames
    @path = path
    @start_x = start_x
    @spr_w = spr_w
    @spr_h = spr_h
    @flip = false
    @active = false
  end

  def draw(args,x, y)
    current_pos = (@active ? (args.state.tick_count * @speed).to_i : 0) % @frames
    args.outputs.sprites << {
                               x: x - cam_x,
                               y: y - cam_y,
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
