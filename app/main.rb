require 'app/rect.rb'
require 'app/actor.rb'
require 'app/color.rb'
require 'app/level.rb'
require 'app/solid.rb'
require 'app/player.rb'
require 'app/platform.rb'

WIDTH = 1280
HEIGHT = 720

def init
  @player = Player.new(0,0,50,50,Color::GREEN)
  Solid.new(0,-100,WIDTH,100,Color::RED)
  Solid.new(0,150,100,100,Color::YELLOW)
  Solid.new(200,400,100,100,Color::YELLOW)
  Platform.new(400,100,300,10,600,300,0.1,Color::RED)
  Platform.new(1000,100,10,500,450,100,0.05,Color::BLUE)
end

def tick args
  init if args.state.tick_count == 0

  @player.move_left if args.inputs.keyboard.key_held.a
  @player.move_right if args.inputs.keyboard.key_held.d
  @player.jump if args.inputs.keyboard.key_down.space

  Level.instance.simulate(args)
  Level.instance.draw(args)
end
