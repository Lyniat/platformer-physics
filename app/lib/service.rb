class Service
  def initialize(time_in_seconds, callback, arguments, repeat)
    @time = time_in_seconds * 60
    @init_time = time_in_seconds
    @callback = callback
    @arguments = arguments
    @repeat = repeat
    Level.instance.add_service(self)
  end

  def simulate(tick_count)
    @time -= 1
    if @time <= 0
      do_work(tick_count)
      destroy unless @repeat
      @time = @init_time * 60 if @repeat
    end
  end

  def do_work(tick_count)
    unless @callback == nil
      @callback.call(@arguments)
    end
  end

  def destroy
    Level.instance.remove_service(self)
  end
end
