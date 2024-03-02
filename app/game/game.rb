def init(args)
  blocks = []

  int_blocks, int_columns, int_rows = map_get_int_layer(args, "data/ldtk/sample/simplified/AutoLayers_advanced_demo/IntGrid_layer.csv")
  #int_blocks = map_get_int_layer(map, "AutoLayers_advanced_demo", "IntGrid_layer")

  map_data = args.gtk.parse_json_file("data/ldtk/sample/simplified/AutoLayers_advanced_demo/data.json")
  player_entity = map_data["entities"]["Player"][0]
  player_x = player_entity["x"]
  player_y = player_entity["y"]

  #puts int_blocks

  args.state.map_rt_sky.path = "data/ldtk/sample/simplified/AutoLayers_advanced_demo/Sky.png"
  args.state.map_rt_sky.w = 344
  args.state.map_rt_sky.h = 328

  args.state.int_bg.path = "data/ldtk/sample/simplified/AutoLayers_advanced_demo/IntGrid_layer.png"
  args.state.int_bg.w = 344
  args.state.int_bg.h = 328

  block_size =  8

  player = {
    x: player_x,
    y: player_y - 64,
    w: 6,
    h: 6,
    sprite_w: 8,
    sprite_h: 8,
    x_remainder: 0,
    y_remainder: 0,
    is_riding: false,
    speed_y: 0,
    jump_down: false,
    on_collision_x: :on_player_x_collision,
    on_collision_y: :on_player_y_collision
  }

  args.state.player = player

  player.physics = {}
  player.physics.speed = {}
  player.physics.const = {}
  player.physics.speed.x = 0
  player.physics.speed.y = 0
  player.physics.jump_remain = 0
  player.physics.const.maxfall = 2
  player.physics.const.gravity = 0.21
  player.physics.jumping = false
  player.physics.was_on_ground = false
  player.physics.const.maxrun = 1
  player.physics.const.accel = 0.6
  player.physics.const.deccel = 0.15
  player.physics.const.max_jump_remain = 8
  player.action_buffer = []

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

  int_blocks.w = int_rows
  int_blocks.h = int_columns

  grid.w = int_blocks.w
  grid.h = int_blocks.h
  grid.solid_w = solid_w
  grid.solid_h = solid_h
  grid.x = 0
  grid.y = 0
  grid.data = []

  y = grid.h - 1
  while y >= 0
    x = 0
    while x < grid.w
      if int_blocks[x + y * grid.w] == 1
        grid_solid = {
          is_solid: true,
          meta: {}
        }
        grid.data << grid_solid
      elsif int_blocks[x + y * grid.w] == 5
        grid_solid = {
          is_solid: true,
          jump_through: true
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
    y -= 1
  end

  args.state.grid = grid

  args.state.platforms = [platform_a]

  args.state.solids = [platform_a]
  #args.state.solids << platform_b

  args.state.player_sprite = sprite_create_base("sprites/panda.png", 24, 8, 3, 1)
  sprite_add_animation(args.state.player_sprite, "idle", 0, 0, 1, 1)
  sprite_add_animation(args.state.player_sprite, "walking", 0, 0, 3, 10)
  args.state.player_flipped = false

  args.state.camera = :camera
  args.state.camera_zoom = 4
  args.state.camera_settings = {x: 0, y: 0}

  bg_color = string_to_rgb(map_data["bgColor"])
  args.state.bg_color = [bg_color.r, bg_color.g, bg_color.b]
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
    path: args.state.map_rt_sky.path,
    x: -cam_x,
    y: -cam_y,
    w: args.state.map_rt_sky.w,
    h: args.state.map_rt_sky.h,
  }

  args.render_target(args.state.camera).sprites << {
    path: args.state.int_bg.path,
    x: -cam_x,
    y: -cam_y,
    w: args.state.int_bg.w,
    h: args.state.int_bg.h,
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
    w: args.state.player.sprite_w,
    h: args.state.player.sprite_h,
    source_w: args.state.player_sprite.source_w,
    source_h: args.state.player_sprite.source_h,
    source_x: args.state.player_sprite.source_x,
    source_y: args.state.player_sprite.source_y,
    flip_horizontally: args.state.player_flipped,
  }

  args.outputs[:camera].transient!

  args.outputs.sprites << {
    path: args.state.camera,
    x: 0,
    y: 0,
    w: 1280 * args.state.camera_zoom,
    h: 720 * args.state.camera_zoom,
  }
end

def get_from_action_buffer(buffer, action)
  contains = false
  buffer.each.with_index do |b, i|
    if b == action
      contains = true
      buffer[i] = nil
    end
  end
  contains
end

def simulate_player(args)
  player = args.state.player
  solids = args.state.solids
  grid = args.state.grid

  #get_from_action_buffer
  player.on_ground = !actor_get_solid_below(player, solids, grid).nil?

  if player.on_ground
    player.action_buffer.append("ground")
  else
    player.action_buffer.append(nil)
  end

  if !player.on_ground
    player.physics.const.accel = 0.04
  end

  if args.inputs.keyboard.key_held.a or args.inputs.keyboard.key_held.left
    if player.physics.speed.x > 0
      player.physics.speed.x = 0
    end
    player.physics.speed.x -= player.physics.const.accel
    sprite_set_animation(args.state.player_sprite, "walking")
    args.state.player_flipped = true
  elsif args.inputs.keyboard.key_held.d or args.inputs.keyboard.key_held.right
    if player.physics.speed.x < 0
      player.physics.speed.x = 0
    end
    player.physics.speed.x += player.physics.const.accel
    sprite_set_animation(args.state.player_sprite, "walking")
    args.state.player_flipped = false
  else
    sign = player.physics.speed.x <=> 0
    player.physics.speed.x = player.physics.speed.x * player.physics.const.deccel
    sprite_set_animation(args.state.player_sprite, "idle")
  end

  if player.physics.speed.x.abs > player.physics.const.maxrun
    sign = player.physics.speed.x <=> 0
    player.physics.speed.x = sign * player.physics.const.maxrun
  end

  actor_move_x(player, solids, grid, player.physics.speed.x)

  #if args.inputs.keyboard.key_down.space and !actor_get_solid_below(player, solids, grid).nil?
  #  player.speed_y = 4
  #end
  #

  touch_ceiling = !actor_get_solid_above(player, solids, grid).nil?

  if touch_ceiling
    player.physics.speed.y = 0
  end

  #player.speed_y += args.state.gravity
  local_gravity = player.physics.const.gravity

  #if player.physics.speed.y <= 0.15
  #  local_gravity *= 0.5
  #end

  if !player.on_ground
      player.physics.speed.y -= local_gravity
  else
    player.physics.speed.y = 0
  end

  if player.physics.speed.y < -player.physics.const.maxfall
    player.physics.speed.y = -player.physics.const.maxfall
  end

  if args.inputs.keyboard.key_down.space
    jump_allowed = player.on_ground
    if !jump_allowed
      jump_allowed = get_from_action_buffer(player.action_buffer, "ground")
    end
    if jump_allowed
      player.physics.jump_remain = player.physics.const.max_jump_remain
      player.physics.speed.y = 2
    end
  elsif args.inputs.keyboard.key_held.space
    if player.physics.jump_remain > 0
      player.physics.speed.y *= 1.1
    end
  end

  player.physics.jump_remain -= 1

  actor_move_y(player, solids, grid, player.physics.speed.y)

  i = 0

  if player.action_buffer.length > 5
    player.action_buffer.shift
  end
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

def on_player_x_collision(actor, solid, squish_actor)
  false if solid.jump_through
end

def on_player_y_collision(actor, solid, squish_actor)
  if solid.jump_through
    if actor.speed_y >= 0 or actor.y < solid.y + solid.h or actor.jump_down == true
      return false
    end
  end
  actor.speed_y = 0
  true
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

  draw_debug_grid(args)
end

def draw_debug_grid(args)
  grid = args.state.grid
  #grid.w = 14 #int_blocks.w
  #grid.h = 14 #int_blocks.h
  #grid.solid_w = solid_w
  #grid.solid_h = solid_h
  #grid.x = 0
  #grid.y = 0
  #grid.data = []

  cam_x = args.state.camera_settings.x
  cam_y = args.state.camera_settings.y

  grid_w = grid.w
  grid_h = grid.h
  grid_cells = grid_w * grid_h
  solid_w = grid.solid_w
  solid_h = grid.solid_h
  grid_cells.map_with_index do |i|
    # i = x + y * grid.w # i - x = y * grid.w # -x = y * grid.w - i # x = - y * grid.w + i
    x = (i % grid_w)
    y = (i / grid_w).floor
    next if !grid.data[i].is_solid
    args.outputs.debug << {
      x: (x *  solid_w * args.state.camera_zoom) - cam_x * args.state.camera_zoom,
      y: (y * solid_h * args.state.camera_zoom) - cam_y * args.state.camera_zoom,
      # x: x - cam_x * args.state.camera_zoom,
      # y: y - cam_y * args.state.camera_zoom,
      w: solid_w * args.state.camera_zoom,
      h: solid_h  * args.state.camera_zoom,
      r: 255,
      g: 0,
      b: 0,
      a: 100,
      primitive_marker: :solid }  
  end
end
