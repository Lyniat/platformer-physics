def init(args)
  blocks = []

  block_size = 8
  i = 0
  while i < 20
    blocks << {
      x: i * block_size,
      y: 0,
      w: block_size,
      h: block_size,
      path: "sprites/platform_3.png",
      x_remainder: 0,
      y_remainder: 0,
      riders: []
    }
    i += 1
  end

  args.state.solids = blocks

  player = {
    x: block_size,
    y: block_size,
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
  grid_w = 40
  grid_h = 20
  solid_w = block_size
  solid_h = block_size

  grid.w = grid_w
  grid.h = grid_h
  grid.solid_w = solid_w
  grid.solid_h = solid_h
  grid.x = 0
  grid.y = 0
  grid.data = []

  y = 0
  while y < grid_h
    x = 0
    while x < grid_w
      if y % 5 == 0 and ((x + y) % 8 != 0 and (x + y) % 8 != 1)
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

  args.state.solids << platform_a
  #args.state.solids << platform_b

  args.state.player_sprite = sprite_create_base("sprites/panda_sheet.png", 72, 16, 6, 1)
  sprite_add_animation(args.state.player_sprite, "idle", 0, 0, 1, 1)
  sprite_add_animation(args.state.player_sprite, "walking", 0, 0, 3, 10)

  args.state.camera = :camera
  args.state.camera_zoom = 4
end

def draw(args)
  #args.outputs.sprites << args.state.player

  sprite_update_animation(args.state.player_sprite)

  args.render_target(args.state.camera).sprites << {
    path: args.state.player_sprite.path,
    x: args.state.player.x,
    y: args.state.player.y,
    w: 12,
    h: 16,
    source_w: args.state.player_sprite.source_w,
    source_h: args.state.player_sprite.source_h,
    source_x: args.state.player_sprite.source_x,
    source_y: args.state.player_sprite.source_y,
  }

  args.render_target(args.state.camera).sprites << args.state.solids

  grid = args.state.grid
  grid_x = grid.x
  grid_y = grid.y
  solid_w = grid.solid_w
  solid_h = grid.solid_h

  y = 0
  while y < grid.h
    x = 0
    while x < grid.w
      if grid.data[x + y * grid.w].is_solid
        args.render_target(args.state.camera).sprites << {
          path: "sprites/platform_3.png",
          x: grid_x + x * solid_w,
          y: grid_y + y * solid_h,
          w: solid_w,
          h: solid_h
        }
      end
      x += 1
    end
    y += 1
  end

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
