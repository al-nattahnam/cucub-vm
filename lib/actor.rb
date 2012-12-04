require 'fiber'

module Cucub
  class Actor
    def initialize(cucub_object)
      @state = :alive

      @cucub_object = cucub_object

      set_fiber
      self
    end

    def set_fiber
      @fiber = Fiber.new { |args, origin|
        while alive?
          $stdout.puts "> at Actor"
          msg = args.shift
          $stdout.puts msg.inspect

          message = read_message(msg)
          play message

          #if msg == "exit"
          #  self.kill
          #  origin.yield
          #end

          origin.transfer
        end
      }
    end

    def process(msg)
      message = read_message(msg)
      play message
    end

    def read_message(message)
      $stdout.puts "Incoming message: #{message.inspect}"
      message.unlock(:msgpack)
      $stdout.puts "Incoming message, unlocked: #{message.inspect}"

      message
    end

    def play(message)
      if message.additionals
        @cucub_object.send(message.action.to_sym, *message.additionals)
      else
        @cucub_object.send(message.action.to_sym)
      end
    end

    def wire(msg)
      @fiber.transfer(msg, Fiber.current)
    end

    def kill
      $stdout.puts "Suiciding me."
      @state = :dead
    end

    def fiber_state
      @fiber.alive?
    end

    def alive?
      @state == :alive
    end
  end
end
