require 'app/lib/camera.rb'
require 'app/game/player_camera.rb'
require 'app/lib/rect.rb'
require 'app/lib/dummy.rb'
require 'app/lib/actor.rb'
require 'app/lib/drawable/color.rb'
require 'app/lib/drawable/drawable.rb'
require 'app/lib/drawable/sprite.rb'
require 'app/lib/level.rb'
require 'app/lib/solid.rb'
require 'app/lib/projectile.rb'
require 'app/game/arrow.rb'
require 'app/game/player.rb'
require 'app/game/platform.rb'
require 'app/game/platform_linear.rb'
require 'app/game/platform_circle.rb'
require 'app/lib/drawable/box.rb'
require 'app/lib/drawable/animation.rb'
require 'app/lib/service.rb'
require 'app/game/map_loader.rb'
require 'app/lib/map.rb'

WIDTH = 1280
HEIGHT = 720

def init args
  init_objects
  @player = Player.new(0, 250, 50, 50 * 2)
  @camera = PlayerCamera.new(args, @player)
  Level.instance.set_camera(@camera)
  Level.instance.enable_performance_check(750) # lower number might increase performance but also can cause bugs
  @show_debug = true
  @paused = false
  @resetting = false
end

def init_objects
  # maps have currently bad performance
  MapLoader.new(54, 35, 8, "/sprites/tiles.png", 24, 21, "/data/map.csv", "/data/tiles.json", 8)
  cloud_block = Sprite.new(100, 100, "/sprites/cloud_block.png", 0, 0, 16, 16)
  Solid.new(0, -100, WIDTH, 100, Box.new(WIDTH, 100, Color::RED))
  Solid.new(0, 150, 100, 100, cloud_block)
  Solid.new(200, 400, 100, 100, cloud_block)

  platform_1 = Sprite.new(300, 50, "/sprites/platform.png", 0, 0, 48, 8)
  PlatformCircle.new(300, 100, 300, 50, 0.02, platform_1, 100)

  platform_2 = Sprite.new(50, 300, "/sprites/platform_2.png", 0, 0, 8, 48)
  PlatformLinear.new(800, 120, 50, 300, 0.02, platform_2, 1200, 120)
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
  @player = Player.new(0, 0, 50, 50 * 2)
  @camera = PlayerCamera.new(args, @player)
  Level.instance.set_camera(@camera)
  @resetting = false
end
