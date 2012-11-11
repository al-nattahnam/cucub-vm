require 'fiber'

module Cucub
  class Actor
    def initialize
      @state = :alive
      set_fiber
      self
    end

    def set_fiber
      @fiber = Fiber.new { |args, origin|
        while alive?
          $stdout.puts "> at Actor"
          msg = args.shift
          puts msg

          #if msg == "exit"
          #  self.kill
          #  origin.yield
          #end

          # play

          origin.transfer
        end
      }
    end

    def wire(msg)
      @fiber.transfer(msg, Fiber.current)
    end

    def kill
      $stdout.puts "Suiciding me."
      @state = :dead
      #@fiber.resume
    end

    def fiber_state
      @fiber.alive?
    end

    def alive?
      @state == :alive
    end
  end
end
