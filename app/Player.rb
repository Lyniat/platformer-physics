class Player
  attr_reader :actor

  ACCELERATION = 0.1
  NEG_ACCELERATION = 0.9
  JUMP_ACCELERATOIN = 0.5
  JUMP_V = 3
  MAX_V_X = 4
  MAX_V_Y = -25
  GRAVITY = -0.3
  MAX_JUMP_FRAMES = 15

  def initialize(actor)
    @actor = actor
    @was_on_ground = false
    #@a_x = 0
    @v_x = 0
    #@a_y = 0
    @v_y = 0
    @jump_frames_remain = 0
  end

  def simulate(physics)
    k_jump = gtk_state.in.k_jump
    k_dash = gtk_state.in.k_dash
    k_climb = gtk_state.in.k_climb

    k_up = gtk_state.in.k_up
    k_down = gtk_state.in.k_down
    k_left = gtk_state.in.k_left
    k_right = gtk_state.in.k_right

    if !@was_on_ground
        @a_y = ACCELERATION
    end

    if k_left.held
        if @v_x > 0
            @v_x = 0
        end
        @v_x -= ACCELERATION
    elsif k_right.held
        if @v_x < 0
            @v_x = 0
        end
        @v_x += ACCELERATION
    else
        sign = @v_x <=> 0
        @v_x = @v_x * NEG_ACCELERATION
    end

    if @v_x.abs > MAX_V_X
        sign = @v_x <=> 0
        @v_x = sign * MAX_V_X
    end

    @was_on_ground = @actor.is_riding
    @actor.move_x(physics, @v_x).nil?

    if !@was_on_ground
        puts "no ground"
        @v_y += GRAVITY
    else
        @v_y = 0
    end

    if @v_y < MAX_V_Y
        @v_y = MAX_V_Y
    end

    if k_jump.down
        jump_allowed = @was_on_ground
        if jump_allowed
            @jump_frames_remain = MAX_JUMP_FRAMES
            @v_y = JUMP_V
        end
    elsif k_jump.held
        if @jump_frames_remain > 0
            @v_y += JUMP_ACCELERATOIN
        end
    end

    puts @v_y

    @jump_frames_remain -= 1

    @actor.move_y(physics, @v_y).nil?

  end
end