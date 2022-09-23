WIDTH = 1280
HEIGHT = 720
SCALE = 8
TILE_SIZE = 8

def init args
  init_objects
  @player = Player.new(TILE_SIZE * SCALE, TILE_SIZE * SCALE, 50, 50 * 2)
  @camera = PlayerCamera.new(args, @player)
  Level.instance.set_camera(@camera)
  Level.instance.enable_performance_check(300) # lower number might increase performance but also can cause bugs
  @show_debug = false
  @paused = false
  @resetting = false
end

def init_objects
  MapLoader.new(54, 35, TILE_SIZE, "/sprites/tiles.png", 24, 21, "/data/map.csv", "/data/tiles.json", SCALE)

  platform_1 = Sprite.new(TILE_SIZE * SCALE * 2, TILE_SIZE * SCALE, "/sprites/platform.png", 0, 0, 48, 8)
  x = 19 * TILE_SIZE * SCALE
  y = 15 * TILE_SIZE * SCALE
  PlatformLinear.new(x, 0, TILE_SIZE * SCALE * 2, TILE_SIZE * SCALE, 0.01, platform_1, x, y)

end

def tick args
  $args = args
  init(args) if args.state.tick_count == 0

  @show_debug = !@show_debug if args.inputs.keyboard.key_down.escape
  @paused = !@paused if args.inputs.keyboard.key_down.backspace
  Level.instance.debug(@show_debug)
  Level.instance.pause(@paused)

  unless @paused
    @player.move_left if args.inputs.keyboard.key_held.a
    @player.move_right if args.inputs.keyboard.key_held.d
    @player.climb if args.inputs.keyboard.key_held.shift_left
    @player.move_up if args.inputs.keyboard.key_held.w
    @player.move_down if args.inputs.keyboard.key_held.s
    @player.jump if args.inputs.keyboard.key_down.space
    @player.fire(@camera.mouse_x, @camera.mouse_y) if args.inputs.mouse.click
  end

  Level.instance.simulate(args)
  Level.instance.draw(args)

  if @player.dead and !@resetting
    Service.new(2, method(:reset), {}, false)
    @resetting = true
  end

  args.outputs.labels << [0, HEIGHT, "move: W, A, S, D", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 20, "jump: SPACE", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 40, "climb: SHIFT", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 60, "fire: MOUSE", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 80, "debug: ESCAPE", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 100, "pause: BACKSPACE", 0, 0, 255, 0, 0]

  args.outputs.labels << [0, HEIGHT - 300, "actors: #{Level.instance.actors.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 320, "solids: #{Level.instance.solids.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 340, "services: #{Level.instance.services.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 360, "dummies: #{Level.instance.dummies.length}", 0, 0, 0, 0, 255]
  args.outputs.labels << [0, HEIGHT - 380, "maps: #{Level.instance.maps.length}", 0, 0, 0, 0, 255]

end

def reset args
  @player = Player.new(0, 250, 50, 50 * 2)
  @camera = PlayerCamera.new(args, @player)
  Level.instance.set_camera(@camera)
  @resetting = false
end