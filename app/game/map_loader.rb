class MapLoader
  def initialize(width, height, tile_size, atlas, atlas_width, atlas_height, data, information, scale)
    @width = width
    @height = height
    @tile_size = tile_size
    @atlas = atlas
    @atlas_width = atlas_width
    @atlas_height= atlas_height
    @data = data
    @information = information
    @scale = scale

    create_map
  end

  def create_map
    infos = $args.gtk.parse_json_file(@information)
    passable_information = infos["passable"]
    jump_through_information = infos["jump_through"]
    ladder_information = infos["ladder"]

    new_passable = []
    i = 0
    while i < passable_information.length
      original_passable = passable_information[i]
      original_p_x = original_passable % @atlas_width
      original_p_y = (original_passable / @atlas_width).floor
      new_p_y = @atlas_height - 1 - original_p_y
      new_passable << original_p_x + new_p_y * @atlas_width
      i += 1
    end

    # until ladders are not implemented, handle them as passable
    i = 0
    while i < ladder_information.length
      original_ladder = ladder_information[i]
      original_l_x = original_ladder % @atlas_width
      original_l_y = (original_ladder / @atlas_width).floor
      new_l_y = @atlas_height - 1 - original_l_y
      new_passable << original_l_x + new_l_y * @atlas_width
      i += 1
    end

    new_jump_through = []
    i = 0
    while i < jump_through_information.length
      original_jump_through = jump_through_information[i]
      original_j_x = original_jump_through % @atlas_width
      original_j_y = (original_jump_through / @atlas_width).floor
      new_j_y = @atlas_height - 1 - original_j_y
      new_jump_through << original_j_x + new_j_y * @atlas_width
      i += 1
    end

    new_infos = {}
    new_infos["passable"] = new_passable
    new_infos["jump_through"] = new_jump_through

    data = $args.gtk.read_file(@data)
    data_array = []
    lines = data.split("\n")

    l = 0
    length_l = lines.length
    while l < length_l
      numbers = lines[l].split(",")
      length_n = numbers.length
      n = 0
      while n < length_n
        original_tile = numbers[n].to_i
        original_x = original_tile % @atlas_width
        original_y = (original_tile / @atlas_width).floor
        new_y = @atlas_height - 1 - original_y
        data_array[(@height - 1 - l) * length_n + n] = original_x + new_y * @atlas_width
        n += 1
      end
      l += 1
    end

    map = Map.new(@width, @height, @tile_size, @atlas, @atlas_width, data_array, new_infos, @scale)
  end
end
