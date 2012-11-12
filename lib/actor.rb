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

          message = read_message(msg[1])
          play message

          #if msg == "exit"
          #  self.kill
          #  origin.yield
          #end

          # play

          origin.transfer
        end
      }
    end

    def read_message(message_txt)
      message = {}
      message[:action] = message_txt.split(";")[0]
      message[:params] = message_txt.split(";")[1].split(",") if message_txt.split(";")[1]
      message
    end

    def play(message) #(method_name, *args)
      if message.has_key?(:params) #args
        @cucub_object.send(message[:action], *message[:params])
      else
        @cucub_object.send(message[:action])
      end
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
