class PlayerCamera < Camera

  FREE_SPACE = 100

  def initialize(player, w, h, bound_left = nil, bound_right = nil, bound_down = nil, bound_up = nil)
    @player = player
    super(player.x, player.y, w, h, bound_left, bound_right, bound_down, bound_up)
  end

  def update
    mid_x = @player.get_center_h
    mid_y = @player.get_center_v

    @x = @x.clamp(mid_x - FREE_SPACE - WIDTH / 2, mid_x + FREE_SPACE - WIDTH / 2)
    @y = @y.clamp(mid_y - FREE_SPACE - HEIGHT / 2, mid_y + FREE_SPACE -  HEIGHT / 2)
    super
  end
end
