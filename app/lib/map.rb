class Map
  def initialize(width, height, tile_size, atlas, atlas_width, data, information, scale)
    @width = width
    @height = height
    @tile_size = tile_size
    @atlas = atlas
    @atlas_width = atlas_width
    @data = data
    @information = information
    @scale = scale

    create_map
  end

  def create_map
    h = 0
    while h < @height
      w = 0
      while w < @width

        tile = @data[h * @width + w]

        passable_information = @information["passable"]

        x = tile % @atlas_width
        y = (tile / @atlas_width).floor
        x_pos = w * @tile_size * @scale
        y_pos = h * @tile_size * @scale
        drawable = Sprite.new(@tile_size, @tile_size, @atlas, x, y, @tile_size, @tile_size, @scale, @scale)

        if passable_information.include?(tile)
          Dummy.new(x_pos, y_pos, @tile_size * @scale, @tile_size * @scale, drawable)
        else
          Solid.new(x_pos, y_pos, @tile_size * @scale, @tile_size * @scale, drawable)
        end

        w += 1
      end
      h += 1
    end
  end
end
