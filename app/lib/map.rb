class Map

  TILE_EMPTY = 0
  TILE_SOLID = 1
  TILE_JUMP_THROUGH = 2

  attr_reader :width, :height
  def initialize(width, height, tile_size, atlas, atlas_width, data, information, scale)
    @width = width
    @height = height
    @tile_size = tile_size
    @atlas = atlas
    @atlas_width = atlas_width
    @data = data
    @information = information
    @scale = scale
    @tiles = []
    @solids = []
    @riders = []

    @debug_rects = []

    create_map
    Level.instance.add_map(self)
  end

  def create_map
    h = 0
    while h < @height
      w = 0
      while w < @width

        tile = @data[h * @width + w]

        passable_information = @information["passable"]
        jump_information = @information["jump_through"]

        x = tile % @atlas_width
        y = (tile / @atlas_width).floor
        x_pos = w * @tile_size
        y_pos = h * @tile_size
        drawable = {x: x_pos,
                    y: y_pos,
                    w: @tile_size,
                    h: @tile_size,
                    path: @atlas,
                    source_x: x * @tile_size,
                    source_y: y * @tile_size,
                    source_w: @tile_size,
                    source_h: @tile_size}

        passable = false
        jump_through = false
        if passable_information.include?(tile)
          passable = true
        else
          @solids[h * @width + w] = Rect.new(x_pos * @scale, y_pos * @scale, @tile_size * @scale, @tile_size * @scale)
        end

        if jump_information.include?(tile)
          jump_through = true
        end

        add_tiles(drawable)

        if passable
          @tiles[h * @width + w] = TILE_EMPTY
        elsif jump_through
          @tiles[h * @width + w] = TILE_JUMP_THROUGH
        else
          @tiles[h * @width + w] = TILE_SOLID
        end

        w += 1
      end
      h += 1
    end

    spr = Sprite.new(@tile_size * @scale * @width, @tile_size * @scale * @height, :map_tiles, 0, 0, @tile_size * @width, @tile_size * @height)
    Dummy.new(0, 0, @tile_size * @scale * @width, @tile_size * @scale * @height, spr)
  end

  def add_tiles(drawable)
    $args.render_target(:map_tiles).sprites << drawable
  end

  def get_tile_at(x, y)
    @tiles[y * @width + x]
  end

  def get_solid_at(x, y)
    @solids[y * @width + x]
  end

  def get_solids_at(x, y, dir_x, dir_y)
    solids = []

    _x = (x / (@tile_size * @scale)).floor
    _y = (y / (@tile_size * @scale)).floor

    i = -1
    while i < 3
      j = -1
      while j < 3
        s = @solids[(_y + i) * @width + _x + j]
        unless s.nil?
          tile = @tiles[(_y + i) * @width + _x + j]
          case tile
          when TILE_SOLID
            solids << s
          when TILE_JUMP_THROUGH
            # only triggers if movement direction is downwards and actor is at highest point of solid
            if dir_y < 0 && y == (_y + i + 1) * @tile_size * @scale
              solids << s
            end
          end
        end
        j += 1
      end
      i += 1
    end

    @debug_rects += solids
    solids
  end

  def add_rider(actor)
    @riders << actor unless @riders.include?(actor)
  end

  def debug_draw(tick_count)
    @debug_rects.each do |rect|
      rect.debug_draw(tick_count, Color::ORANGE)
    end
    @debug_rects.clear
  end
end
