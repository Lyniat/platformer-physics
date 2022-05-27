class PlayerCamera < Camera

  FREE_SPACE = 100

  def initialize(tick_count, player)
    @player = player
    super(tick_count, player.x, player.y)
  end

  def update
    mid_x = @player.get_center_h
    mid_y = @player.get_center_v

    @x = @x.clamp(mid_x - FREE_SPACE - WIDTH / 2, mid_x + FREE_SPACE - WIDTH / 2)
    @y = @y.clamp(mid_y - FREE_SPACE - HEIGHT / 2, mid_y + FREE_SPACE -  HEIGHT / 2)
  end
end
