require 'app/lib/camera.rb'
require 'app/game/player_camera.rb'
require 'app/lib/rect.rb'
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
require 'app/lib/drawable/box.rb'
require 'app/lib/drawable/animation.rb'

WIDTH = 1280
HEIGHT = 720

def init args
  @player = Player.new(0,0,100,100)
  Solid.new(0,-100,WIDTH,100,Box.new(WIDTH,100,Color::RED))
  Solid.new(0,150,100,100,Box.new(100,100,Color::YELLOW))
  Solid.new(200,400,100,100,Box.new(100,100,Color::YELLOW))
  Platform.new(400,100,300,10,600,300,0.1,Box.new(300,10,Color::RED))
  Platform.new(1000,100,10,500,450,100,0.05,Box.new(10,500,Color::BLUE))

  @camera = PlayerCamera.new(args, @player)
  Level.instance.add_camera(@camera)
  @show_debug = false
end

def tick args
  init(args) if args.state.tick_count == 0

  @player.move_left if args.inputs.keyboard.key_held.a
  @player.move_right if args.inputs.keyboard.key_held.d
  @player.climb if args.inputs.keyboard.key_held.shift_left
  @player.move_up if args.inputs.keyboard.key_held.w
  @player.move_down if args.inputs.keyboard.key_held.s
  @player.jump if args.inputs.keyboard.key_down.space
  @player.fire(@camera.mouse_x, @camera.mouse_y) if args.inputs.mouse.click

  @show_debug = !@show_debug if args.inputs.keyboard.key_down.escape
  Level.instance.debug(@show_debug)

  Level.instance.simulate(args)
  Level.instance.draw(args)

  args.outputs.labels << [0, HEIGHT, "move: W, A, S, D", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 20, "jump: SPACE", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 40, "climb: SHIFT", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 60, "fire: MOUSE", 0, 0, 255, 0, 0]
  args.outputs.labels << [0, HEIGHT - 80, "debug: ESCAPE", 0, 0, 255, 0, 0]

  # Level.instance.destroy if args.inputs.keyboard.key_down.escape
end
