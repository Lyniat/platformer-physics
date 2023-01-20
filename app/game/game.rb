def init(args)
  #map = map_load_ldtk("data/ldtk/map.ldtk")
  map = map_load_ldtk("data/ldtk/sample.ldtk")

  #args.state.map_rt_bg = map_get_sprite_ldtk(args, map, "Level_0", "Background")
  args.state.map_rt_bg = map_get_sprite_ldtk(args, map, "AutoLayers_advanced_demo", "IntGrid_layer")
  args.state.map_rt_sky = map_get_sprite_ldtk(args, map, "AutoLayers_advanced_demo", "Sky")
  blocks = []

  #int_blocks = map_get_int_layer(map, "Level_0", "Meta")
  int_blocks = map_get_int_layer(map, "AutoLayers_advanced_demo", "IntGrid_layer")


  entities = map_get_entities_layer(map, "AutoLayers_advanced_demo", "Entities")

  player_entity = entities.data["Player"]

  #puts int_blocks

  block_size = 8

  player = {
    x: player_entity.x,
    y: player_entity.y,
    w: 12,
    h: 16,
    x_remainder: 0,
    y_remainder: 0,
    is_riding: false,
    speed_y: 0,
    on_collision_y: :on_player_y_collision
  }

  args.state.player = player

  args.state.actors = []
  args.state.actors << player

  args.state.gravity = -8 / 60

  platform_a = {
    x: 20,
    y: 0,
    w: block_size * 2,
    h: block_size,
    path: "sprites/platform.png",
    x_remainder: 0,
    y_remainder: 0,
    riders: [],
    start_x: 20,
    start_y: 0,
    stop_x: 20,
    stop_y: 50,
    speed: 0.01
  }

  platform_b = {
    x: 40,
    y: 8,
    w: block_size * 2,
    h: block_size,
    path: "sprites/platform.png",
    x_remainder: 0,
    y_remainder: 0,
    riders: [],
    start_x: 40,
    start_y: 8,
    stop_x: 70,
    stop_y: 8,
    speed: 0.01
  }

  # create solid grid

  grid = {}
  solid_w = block_size
  solid_h = block_size

  grid.w = int_blocks.w
  grid.h = int_blocks.h
  grid.solid_w = solid_w
  grid.solid_h = solid_h
  grid.x = 0
  grid.y = 0
  grid.data = []

  y = 0
  while y < grid.h
    x = 0
    while x < grid.w
      if int_blocks.data[x + y * grid.w] == 1
        grid_solid = {
          is_solid: true,
          meta: {}
        }
        grid.data << grid_solid
      else
        grid_solid = {
          is_solid: false
        }
        grid.data << grid_solid
      end
      x += 1
    end
    y += 1
  end

  args.state.grid = grid

  args.state.platforms = [platform_a]

  args.state.solids = [platform_a]
  #args.state.solids << platform_b

  args.state.player_sprite = sprite_create_base("sprites/panda_sheet.png", 72, 16, 6, 1)
  sprite_add_animation(args.state.player_sprite, "idle", 0, 0, 1, 1)
  sprite_add_animation(args.state.player_sprite, "walking", 0, 0, 3, 10)

  args.state.camera = :camera
  args.state.camera_zoom = 4
  args.state.camera_settings = {x: 0, y: 0}

  bg_color = map.levels[:AutoLayers_advanced_demo].color
  args.state.bg_color = [bg_color.r, bg_color.g, bg_color.b]

  puts args.state.bg_color
end

def draw(args)
  #args.outputs.sprites << args.state.player
  # set camera

  args.outputs.background_color = args.state.bg_color

  args.state.camera_settings.x = (args.state.player.x + args.state.player.w / 2) - (1280 / args.state.camera_zoom) / 2
  args.state.camera_settings.y = (args.state.player.y + args.state.player.h / 2) - (720 / args.state.camera_zoom) / 2

  cam_x = args.state.camera_settings.x
  cam_y = args.state.camera_settings.y

  #args.render_target(args.state.camera).sprites << args.state.solids
  args.render_target(args.state.camera).sprites << {
    path: args.state.map_rt_sky,
    x: -cam_x,
    y: -cam_y,
    w: 1280,
    h: 720
  }

  args.render_target(args.state.camera).sprites << {
    path: args.state.map_rt_bg,
    x: -cam_x,
    y: -cam_y,
    w: 1280,
    h: 720
  }

  args.state.solids.each do |solid|
    args.render_target(args.state.camera).sprites << {
      path: solid.path,
      x: solid.x - cam_x,
      y: solid.y - cam_y,
      w: solid.w,
      h: solid.h
    }
  end

  sprite_update_animation(args.state.player_sprite)

  args.render_target(args.state.camera).sprites << {
    path: args.state.player_sprite.path,
    x: args.state.player.x - cam_x,
    y: args.state.player.y - cam_y,
    w: 12,
    h: 16,
    source_w: args.state.player_sprite.source_w,
    source_h: args.state.player_sprite.source_h,
    source_x: args.state.player_sprite.source_x,
    source_y: args.state.player_sprite.source_y,
  }

  args.outputs.sprites << {
    path: args.state.camera,
    x: 0,
    y: 0,
    w: 1280 * args.state.camera_zoom,
    h: 720 * args.state.camera_zoom,
  }
end

def simulate_player(args)
  player = args.state.player
  solids = args.state.solids
  grid = args.state.grid

  speed_x = 0
  if args.inputs.keyboard.key_held.a or args.inputs.keyboard.key_held.left
    speed_x = -0.5
    sprite_set_animation(args.state.player_sprite, "walking")
  elsif args.inputs.keyboard.key_held.d or args.inputs.keyboard.key_held.right
    speed_x = 0.5
    sprite_set_animation(args.state.player_sprite, "walking")
  else
    sprite_set_animation(args.state.player_sprite, "idle")
  end

  actor_move_x(player, solids, grid, speed_x)

  if args.inputs.keyboard.key_down.space and !actor_get_solid_below(player, solids, grid).nil?
    player.speed_y = 4
  end

  player.speed_y += args.state.gravity

  actor_move_y(player, solids, grid, player.speed_y)
end

def simulate_platforms(args)
  platforms = args.state.platforms

  platforms.each do |platform|
    progress = (Math.sin(args.state.tick_count * platform.speed)) / 4.0
    x = platform.start_x * (1.0 - progress) + platform.stop_x * progress
    y = platform.start_y * (1.0 - progress) + platform.stop_y * progress
    solid_move(platform, args.state.actors, args.state.solids, args.state.grid, x - platform.x, progress)
  end
end

def on_player_y_collision(actor, solid, squish_actor)
  actor.speed_y = 0
end

def tick args
  ticks = args.state.tick_count

  init(args) if ticks == 0

  simulate_player(args)

  actors = args.state.actors
  solids = args.state.solids
  grid = args.state.grid

  actors.each do |actor|
    actor_simulate(actor, solids, grid)
  end

  simulate_platforms(args)

  solids.each do |solid|
    solid_simulate(solid)
  end

  draw(args)
end
