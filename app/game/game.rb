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

  actor_move_x(player, solids, speed_x)

  if args.inputs.keyboard.key_down.space and !actor_get_solid_below(player, solids).nil?
    player.speed_y = 4
  end

  player.speed_y += args.state.gravity

  actor_move_y(player, solids, player.speed_y)
end

def simulate_platforms(args)
  platforms = args.state.platforms

  platforms.each do |platform|
    progress = (Math.sin(args.state.tick_count * platform.speed)) / 4.0
    x = platform.start_x * (1.0 - progress) + platform.stop_x * progress
    y = platform.start_y * (1.0 - progress) + platform.stop_y * progress
    solid_move(platform, args.state.actors, args.state.solids, x - platform.x, progress)
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

  actors.each do |actor|
    actor_simulate(actor, solids)
  end

  simulate_platforms(args)

  solids.each do |solid|
    solid_simulate(solid)
  end

  draw(args)
end
