module Cucub
  class Actor
    def initialize
      state = :alive
      set_fiber
    end

    def set_fiber
      @fiber = Fiber.new { |args, origin|
        while alive?
          puts "> at Actor"
          msg = args.shift
          puts msg

          # play

          origin.transfer
        end
      }
    end

    def wire(msg)
      @fiber.transfer(msg, Fiber.current)
    end

    def kill
      @state = :dead
    end

    def alive?
      @state == :alive
    end
  end
end
