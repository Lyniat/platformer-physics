class Level
  attr_reader :actors, :solids, :camera

  @instance = nil

  def initialize
    @camera = nil
    @tick_count = 0
    @paused = false

    # actors
    @actors = []
    @actors_to_add = []
    @actors_to_destroy = []

    # solids
    @solids = []
    @solids_to_add = []
    @solids_to_destroy = []

    # services
    @services = []
    @services_to_add = []
    @services_to_destroy = []

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

  def pause(on)
    @paused = on
  end

  def set_camera(camera)
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

  def add_service service
    @services_to_add << service
  end

  def remove_service service
    @services_to_destroy << service
  end

  def destroy
    @should_destroy = true
  end

  def simulate args
    @tick_count += 1 unless @paused
    if @should_destroy

      @actors.clear
      @actors_to_add.clear
      @actors_to_destroy.clear

      @solids.clear
      @solids_to_add.clear
      @solids_to_destroy.clear

      @services.clear
      @services_to_add.clear
      @services_to_destroy.clear

      @instance = nil
    end

    # cleanup
    # to prevent misbehaviour from entities we only want to add and remove
    # them at the beginning of each frame

    # services
    # add new ones
    @services.concat(@services_to_add)
    @services_to_add.clear
    # destroy old ones
    @services -= @services_to_destroy
    @services_to_destroy.clear

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

    unless @paused
      @services.each do |service|
        service.simulate(@tick_count)
      end

      @actors.each do |actor|
        actor.simulate(@tick_count)
      end

      @solids.each do |solid|
        solid.simulate(@tick_count)
      end
    end
  end

  def draw args
    # first update camera
    @camera&.update

    @solids.each do |solid|
      solid.draw(args.state.tick_count)
    end

    @actors.each do |actor|
      actor.draw(args.state.tick_count)
    end

    debug_draw(args.state.tick_count) if @debug
  end

  def debug_draw tick_count
    @solids.each do |solid|
      solid.debug_draw(tick_count)
    end

    @actors.each do |actor|
      actor.debug_draw(tick_count)
    end
  end

end
