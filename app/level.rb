class Level
  attr_reader :actors, :solids

  @instance = nil

  def initialize
    @actors = []
    @solids = []
  end

  def self.instance
    @instance = Level.new if @instance == nil
    @instance
  end

  def add_actor actor
    @actors << actor
  end

  def remove_actor actor
    @actors.delete(actor)
  end

  def add_solid solid
    @solids << solid
  end

  def remove_solid solid
    @solids.delete(solid)
  end

  def simulate args
    @actors.each do |actor|
      actor.simulate(args)
    end

    @solids.each do |solid|
      solid.simulate(args)
    end
  end

  def draw args
    @solids.each do |solid|
      solid.draw(args)
    end

    @actors.each do |actor|
      actor.draw(args)
    end
  end

end
