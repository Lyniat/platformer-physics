class Sprite
    attr_sprite

    def initialize(x, y, w, h, path, modifier)
      @x = x
      @y = y
      @w = w
      @h = h
      @path = path
      @modifier = modifier
      $args.outputs.static_sprites << self
  end

  def update
    @x = @modifier.x
    @y = @modifier.y
    @w = @modifier.w
    @h = @modifier.h
  end

  def draw_override ffi_draw
      update
      ffi_draw.draw_sprite @x, @y, @w, @h, @path
    end
end