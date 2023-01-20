def map_load_ldtk(file_path)
  data = {}
  data_json = $gtk.parse_json_file(file_path)
  path = file_path.rpartition('/').first + "/"
  tilesets = {}
  data_json["defs"]["tilesets"].each do |tileset|
    tilesets[tileset["uid"]]= {
      :width => tileset["pxWid"],
      :height => tileset["pxHei"],
      :cell_size => tileset["tileGridSize"],
      :identifier => tileset["identifier"].to_sym,
      :path => fix_rel_path(path + tileset["relPath"])
    }
  end
  data.tilesets = tilesets
  data.levels = {}

  data_json["levels"].map do |level|
    level = map_get_level_ldtk(level, tilesets)
    data.levels[level.name.to_sym] = level
  end

  data
end

def map_get_level_ldtk(level, tilesets)
  level_name = level["identifier"].to_sym
  level_iid = level["iid"].to_sym

  px_w = level["pxWid"]
  px_h = level["pxHei"]
  world_x = level["worldX"]
  world_y = level["worldY"]
  hex_color = level["__bgColor"]
  color = hex_to_rgba(hex_color)

  level_data = {}

  level["layerInstances"].map do |layer|
    layer = map_get_layer_ldtk(layer, tilesets)
    level_data[layer.name.to_sym] = layer
  end

  {
    name: level_name,
    iid: level_iid,
    px_w: px_w,
    px_h: px_h,
    x: world_x,
    y: world_y,
    layers: level_data,
    color: color
  }
end

def map_get_layer_ldtk(layer, tilesets)
  # common layer data
  cell_width = layer["__cWid"]
  cell_height = layer["__cHei"]
  cell_size = layer["__gridSize"]
  layer_type = :none
  layer_iid = layer["iid"].to_sym
  identifier = layer["__identifier"]

  data = {
    name: identifier,
    cell_width: cell_width,
    cell_height: cell_height,
    cell_size: cell_size,
    iid: layer_iid,
    tiles: {},
    auto_tiles: {},
    entities: {},
    int_grid: {},
    tileset_path: ""
  }

  case layer["__type"]
  when "Tiles"
    layer_type = :tiles
  when "IntGrid"
    layer_type = :intGrid
  when "Entities"
    layer_type = :entities
  end

  grid_tiles = layer["gridTiles"]
  int_tiles = layer["intGridCsv"]
  auto_tiles = layer["autoLayerTiles"]
  entities = layer["entityInstances"]

  unless grid_tiles.nil?
    if grid_tiles.size > 0
      tileset_id = layer["__tilesetDefUid"]
      tileset = tilesets[tileset_id]
      puts grid_tiles
      puts tileset_id
      tileset_path = tileset[:path]
      data.tiles = map_get_layer_data_tiles_ldtk(grid_tiles, tileset, data)
    end
  end

  unless int_tiles.nil?
    if int_tiles.size > 0
      data.int_grid = map_get_layer_data_int_grid_ldtk(int_tiles, data)
    end
  end

  unless auto_tiles.nil?
    if auto_tiles.size > 0
      tileset_id = layer["__tilesetDefUid"]
      tileset = tilesets[tileset_id]
      tileset_path = tileset[:path]
      data.auto_tiles = map_get_layer_data_tiles_ldtk(auto_tiles, tileset, data)
    end
  end

  unless entities.nil?
    if entities.size > 0
      data.entities = map_get_layer_data_entities_ldtk(entities, data)
    end
  end

  data.layer_type = layer_type
  data.path = tileset_path

  data
end

def map_get_layer_data_tiles_ldtk(tiles, tileset, data)
  tiles.map do |tile|
    sx = tile["src"][0]
    sy = tileset[:height] - tile["src"][1] - tileset[:cell_size]
    x = tile["px"][0]
    y = data.cell_height * data.cell_size - tile["px"][1] - data.cell_size
    f = tile["f"]
    v_flip = false
    h_flip = false
    case f
    when 0
      v_flip = false
      h_flip = false
    when 1
      v_flip = false
      h_flip = true
    when 2
      v_flip = true
      h_flip = false
    when 3
      v_flip = true
      h_flip = true
    end

    {x: x, y: y, sx: sx, sy: sy, w: tileset[:cell_size], h: tileset[:cell_size], f: f, flip_vertically: v_flip, flip_horizontally: h_flip}
  end
end

def map_get_layer_data_int_grid_ldtk(int_tiles, data)
  int_values = Array.new(int_tiles.length)
  int_tiles.each_with_index do |v, i|
    x = i % data.cell_width
    y = i.div(data.cell_width)

    int_values[x + (data.cell_height - 1 - y) * data.cell_width] = v
  end
  int_values
end

def map_get_layer_data_entities_ldtk(entities, data)
  ent_values = {}
  entities.each do |e|
    x = e["__grid"][0] * data.cell_size
    y = (data.cell_height - e["__grid"][1] - 1) * data.cell_size
    w = e["width"]
    h = e["height"]
    name = e["__identifier"]

    ent_values[name] = {name: name,
                        x: x,
                        y: y,
                        w: w,
                        h: h}
  end
  ent_values
end

def map_get_sprite_ldtk(args, world, level, layer)
  level = level.to_sym unless  level.is_a? Symbol
  layer = layer.to_sym unless layer.is_a? Symbol
  layer_to_find =  world.levels[level].layers[layer]
  return if layer_to_find.nil?
  to_draw = layer_to_find.tiles.size > 0 ? layer_to_find.tiles : layer_to_find.auto_tiles
  return if to_draw.size == 0

  dx = 0
  dy = 0
  scale = 1

  data_to_render = to_draw.map do |tile|
    {
      x: ((tile.x - dx) * scale).to_i,
      y: ((tile.y - dy) * scale).to_i,
      w: tile.w * scale,
      h: tile.h * scale,
      source_x: tile.sx,
      source_y: tile.sy,
      source_w: tile.w,
      source_h: tile.h,
      path: layer_to_find.path,
      flip_horizontally: tile.flip_horizontally,
      flip_vertically: tile.flip_vertically
    }
  end

  render_target = "level_#{level}".to_sym
  args.render_target(render_target).sprites << data_to_render
  render_target
end

def map_get_int_layer(world, level, layer)
  level = level.to_sym unless  level.is_a? Symbol
  layer = layer.to_sym unless layer.is_a? Symbol
  layer_to_find =  world.levels[level].layers[layer]
  return if layer_to_find.nil?

  {w: layer_to_find.cell_width,
   h: layer_to_find.cell_height,
   data: layer_to_find.int_grid}
end

def map_get_entities_layer(world, level, layer)
  level = level.to_sym unless  level.is_a? Symbol
  layer = layer.to_sym unless layer.is_a? Symbol
  layer_to_find =  world.levels[level].layers[layer]
  return if layer_to_find.nil?

  {w: layer_to_find.cell_width,
   h: layer_to_find.cell_height,
   data: layer_to_find.entities}
end
