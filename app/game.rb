def gtk_state = $args.state
def gtk_ticks = $args.state.tick_count
def gtk_keyboard = $args.inputs.keyboard
def gtk_keyboard_down = $args.inputs.keyboard.key_down
def gtk_keyboard_up = $args.inputs.keyboard.key_up
def gtk_keyboard_held = $args.inputs.keyboard.key_held
def gtk_keyboard_any_down?(*keys) = keys.any? {|k| $args.inputs.keyboard.key_down?(k)}
def gtk_keyboard_any_up?(*keys) = keys.any? {|k| $args.inputs.keyboard.key_up?(k)}
def gtk_keyboard_any_held?(*keys) = keys.any? {|k| $args.inputs.keyboard.key_held?(k)}

def init
    gtk_state.simulation = Physics.new
    gtk_state.player = {}

    player_actor = Actor.new(40, 600, 64, 64)
    gtk_state.player.actor = player_actor
    gtk_state.player.sprite = Sprite.new(player_actor.x, player_actor.y, player_actor.w, player_actor.h, "sprites/panda_single.png", player_actor)

    gtk_state.player.entity = Player.new(player_actor)

    grid_array = Array.new(40, true)
    grid = Grid.new(0, 0, 32, 32, 40, 0, grid_array)
    gtk_state.grid = grid_array

    gtk_state.simulation.add(player_actor)
    gtk_state.simulation.add(grid)

    gtk_state.in = {}
    gtk_state.in.k_jump = {}
    gtk_state.in.k_dash = {}
    gtk_state.in.k_climb = {}
    gtk_state.in.k_up = {}
    gtk_state.in.k_down = {}
    gtk_state.in.k_left = {}
    gtk_state.in.k_right = {}
end

def tick args

  init if gtk_ticks == 0

  get_input

  gtk_state.player.entity.simulate(gtk_state.simulation)

  gtk_state.simulation.simulate()
end

def get_input
    gtk_state.in.k_jump.down = gtk_keyboard_any_down?(:space)
    gtk_state.in.k_jump.held = gtk_keyboard_any_held?(:space)
    gtk_state.in.k_jump.up = gtk_keyboard_any_up?(:space)

    gtk_state.in.k_dash.down = gtk_keyboard_any_down?(:c, :v)
    gtk_state.in.k_dash.held = gtk_keyboard_any_held?(:c, :v)
    gtk_state.in.k_dash.up = gtk_keyboard_any_up?(:c, :v)

    gtk_state.in.k_climb.down = gtk_keyboard_any_down?(:shift)
    gtk_state.in.k_climb.held = gtk_keyboard_any_held?(:shift)
    gtk_state.in.k_climb.up = gtk_keyboard_any_up?(:shift)

    gtk_state.in.k_up.down = gtk_keyboard_any_down?(:up)
    gtk_state.in.k_up.held = gtk_keyboard_any_held?(:up)
    gtk_state.in.k_up.up = gtk_keyboard_any_up?(:up)

    gtk_state.in.k_down.down = gtk_keyboard_any_down?(:down)
    gtk_state.in.k_down.held = gtk_keyboard_any_held?(:down)
    gtk_state.in.k_down.up = gtk_keyboard_any_up?(:down)

    gtk_state.in.k_left.down = gtk_keyboard_any_down?(:left)
    gtk_state.in.k_left.held = gtk_keyboard_any_held?(:left)
    gtk_state.in.k_left.up = gtk_keyboard_any_up?(:left)

    gtk_state.in.k_right.down = gtk_keyboard_any_down?(:right)
    gtk_state.in.k_right.held = gtk_keyboard_any_held?(:right)
    gtk_state.in.k_right.up = gtk_keyboard_any_up?(:right)
    return
end

def old_code
  get_input(args)

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