class Level
  attr_reader :actors, :solids, :camera

  @instance = nil

  def initialize
    @camera = nil
    @actors = []
    @actors_to_add = []
    @actors_to_destroy = []
    @solids = []
    @solids_to_add = []
    @solids_to_destroy = []
    @should_destroy = false
    @debug = false
  end

  def self.instance
    @instance = Level.new if @instance == nil
    @instance
  end

  def debug(on)
    @debug = on
  end

  def add_camera(camera)
    @camera = camera
  end

  def add_actor actor
    @actors_to_add << actor
  end

  def remove_actor actor
    @actors_to_destroy << actor
  end

  def add_solid solid
    @solids_to_add << solid
  end

  def remove_solid solid
    @solids_to_destroy << solid
  end

  def destroy
    @should_destroy = true
  end

  def simulate args
    if @should_destroy
      @actors.clear
      @actors_to_add.clear
      @actors_to_destroy.clear
      @solids.clear
      @solids_to_add.clear
      @solids_to_destroy.clear
      @instance = nil
    end

    # cleanup
    # to prevent misbehaviour from entities we only want to add and remove
    # them at the beginning of each frame
    # actors
    # add new ones
    @actors.concat(@actors_to_add)
    @actors_to_add.clear
    # destroy old ones
    @actors -= @actors_to_destroy
    @actors_to_destroy.clear

    # solids
    # add new ones
    @solids.concat(@solids_to_add)
    @solids_to_add.clear
    # destroy old ones
    @solids -= @solids_to_destroy
    @solids_to_destroy.clear

    @actors.each do |actor|
      actor.simulate(args)
    end

    @solids.each do |solid|
      solid.simulate(args)
    end
  end

  def draw args
    # first update camera
    @camera&.update
    
    @solids.each do |solid|
      solid.draw(args)
    end

    @actors.each do |actor|
      actor.draw(args)
    end

    debug_draw(args) if @debug
  end

  def debug_draw args
    @solids.each do |solid|
      solid.debug_draw(args)
    end

    @actors.each do |actor|
      actor.debug_draw(args)
    end
  end

end
