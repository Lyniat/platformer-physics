WIDTH = 1280
HEIGHT = 720
TILE_SIZE = 8
CANVAS_WIDTH = 1280 / 8
CANVAS_HEIGHT = 720 / 8
MAP_SCALE = 1

def init args
  init_objects
  map_loader = MapLoader.new(54, 35, TILE_SIZE, "/sprites/tiles.png", 24, 21, "/data/map.csv", "/data/tiles.json", MAP_SCALE)
  @map = map_loader.map
  @map_width = @map.width
  @map_height = @map.height
  @player_rect = Rect.new(2, 0, 8, 14)
  @player = Player.new(TILE_SIZE, TILE_SIZE, 12, 16, @player_rect)
  @camera = PlayerCamera.new(@player, CANVAS_WIDTH, CANVAS_HEIGHT, 0, @map_width * TILE_SIZE, 0, @map_height * TILE_SIZE)
  Level.instance.set_camera(@camera)
  Level.instance.enable_performance_check(300) # lower number might increase performance but also can cause bugs
  @show_debug = false
  @paused = false
  @resetting = false
end

def init_objects
  platform_1 = Sprite.new(TILE_SIZE * 2, TILE_SIZE, "/sprites/platform.png", 0, 0, 48, 8)
  x = 19 * TILE_SIZE
  y = 15 * TILE_SIZE
  PlatformLinear.new(x, 0, TILE_SIZE * 2, TILE_SIZE, 0.01, platform_1, x, y)

  platform_2 = Sprite.new(TILE_SIZE * 2, TILE_SIZE * 3, "/sprites/platform_2.png", 0, 0, 16, 24)
  x_2_start = 36 * TILE_SIZE
  y_2_start = 2 * TILE_SIZE
  x_2_end = 51 * TILE_SIZE
  y_2_end = 8 * TILE_SIZE
  PlatformLinear.new(x_2_start, y_2_start, TILE_SIZE * 2, TILE_SIZE * 3, 0.01, platform_2, x_2_end, y_2_end)
end

def tick args
  $args = args
  init(args) if args.state.tick_count == 0
  if args.inputs.last_active == :controller
    args.state.active_input = args.inputs.controller_one
    args.state.input_mode = :controller
  elsif args.inputs.last_active == :keyboard
    args.state.active_input = args.inputs.keyboard
    args.state.input_mode = :keyboard
  end

  @show_debug = !@show_debug if args.inputs.keyboard.key_down.escape
  @paused = !@paused if args.state.active_input.key_down?(control_mapping[:pause][args.state.input_mode])
  Level.instance.debug(@show_debug)
  Level.instance.pause(@paused)

  unless @paused
    @player.move_left if args.state.active_input.key_held?(control_mapping[:left][args.state.input_mode])
    @player.move_right if args.state.active_input.key_held?(control_mapping[:right][args.state.input_mode])
    @player.climb if args.state.active_input.key_held?(control_mapping[:climb][args.state.input_mode])
    @player.move_up if args.state.active_input.key_held?(control_mapping[:up][args.state.input_mode])
    @player.move_down if args.state.active_input.key_held?(control_mapping[:down][args.state.input_mode])
    if args.state.active_input.key_down_or_held?(control_mapping[:jump][args.state.input_mode])
      @player.jump if args.state.active_input.key_down?(control_mapping[:jump][args.state.input_mode])
      @player.jump_accelerate if args.state.active_input.key_held?(control_mapping[:jump][args.state.input_mode])
    end
    @player.fire(@camera.mouse_x, @camera.mouse_y) if args.inputs.mouse.click
  end

  Level.instance.simulate(args)
  Level.instance.draw(args)

  if @player.dead and !@resetting
    Service.new(2, method(:reset), {}, false)
    @resetting = true
  end

  case args.state.input_mode
  when :keyboard
    args.outputs.labels << [0, HEIGHT, "move: W, A, S, D", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 20, "jump: SPACE", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 40, "climb: SHIFT", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 60, "fire: MOUSE", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 80, "debug: ESCAPE", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 100, "pause: BACKSPACE", 0, 0, 255, 0, 0]
  when :controller
    args.outputs.labels << [0, HEIGHT, "move: d-pad or sticks", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 20, "jump: A", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 40, "climb: R1", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 60, "fire: MOUSE", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 80, "debug: ???", 0, 0, 255, 0, 0]
    args.outputs.labels << [0, HEIGHT - 100, "pause: START", 0, 0, 255, 0, 0]
  end



  args.outputs.labels << [0, HEIGHT - 300, "actors: #{Level.instance.actors.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 320, "solids: #{Level.instance.solids.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 340, "services: #{Level.instance.services.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 360, "dummies: #{Level.instance.dummies.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 380, "maps: #{Level.instance.maps.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 400, "sprites: #{args.outputs.sprites.length}", 0, 0, 0, 0, 255]

  sin_paused_label = Math.sin(args.state.tick_count / 30) * 20
  args.outputs.labels << [WIDTH / 2, HEIGHT / 2 + sin_paused_label, "GAME PAUSED", 15, 1, 255, 255, 0] if @paused
end

def control_mapping
  {
    jump: {
      keyboard: :space,
      controller: :a,
    },
    left: {
      keyboard: :a,
      controller: :left
    },
    right: {
      keyboard: :d,
      controller: :right,
    },
    up: {
      keyboard: :w,
      controller: :up,
    },
    down: {
      keyboard: :s,
      controller: :down,
    },
    climb: {
      keyboard: :shift_left,
      controller: :r1,
    },
    pause: {
      keyboard: :escape,
      controller: :start,
    }
  }
end

def reset args
  @player = Player.new(TILE_SIZE, TILE_SIZE, 12, 16, @player_rect)
  @camera = PlayerCamera.new(@player, CANVAS_WIDTH, CANVAS_HEIGHT,0, @map_width * TILE_SIZE, 0, @map_height * TILE_SIZE)
  Level.instance.set_camera(@camera)
  @resetting = false
end
