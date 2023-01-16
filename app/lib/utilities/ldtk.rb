require 'app/lib/third-party/LDtkBridge.rb'

def map_load_ldtk(path)
  parts = path.rpartition('/')
  folder = parts.first + "/"
  file = parts.last
  LDtk::LDtkBridge.new(folder, file)
end

def map_get_sprite_ldtk(args, world, level, layer)
  level = level.to_sym unless  level.is_a? Symbol
  layer = layer.to_sym unless layer.is_a? Symbol
  level = world.get_level(level)
  layer = level.get_layer(layer)
  render_target = "map_#{world}_#{level}_#{layer}".to_sym
  args.render_target(render_target).sprites << layer.render
  render_target
end

def map_get_int_layer(world, level, layer)
  level = level.to_sym unless  level.is_a? Symbol
  layer = layer.to_sym unless layer.is_a? Symbol
  level = world.get_level(level)
  layer = level.get_layer(layer)

  layer_w = layer.cell_width
  layer_h = layer.cell_height

  tiles = []
  y = 0
  while y < layer_h
    x = 0
    while x < layer_w
      tile = layer.get_int(x, y)
      tiles << tile
      x += 1
    end
    y += 1
  end

  {w: layer_w,
   h: layer_h,
   data: tiles}
end
