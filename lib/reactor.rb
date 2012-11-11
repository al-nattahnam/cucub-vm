require 'singleton'

require 'fiber'

module Cucub
  class Reactor
    include Singleton

    def initialize
      @actors = []
    end

    def run
      plug_actors

      container.resume
    end

    def plug_actors
      @actor = Cucub::Actor.new

      plug_actor(@actor)
    end

    def container
      @reactor_fiber = Fiber.new {
        init_channels
        $stdout.puts "prepared to receive."

        # worker is going to be a Class, fibered-aware, which can receive messages
        # relay(@worker)

        @inbound.receive { |msg|
          $stdout.puts "received: #{msg.inspect}"
          @actors.first.wire(msg)
          $stdout.puts "\n"
        }
      }
    end

    def plug_actor(actor)
      @actors << actor
      # maybe send plugged event ?
    end

    def kill_actors
      $stdout.puts "4. Kill Actors"
      @actors.each { |actor| actor.kill }
      $stdout.puts "5. Killed"
    end

    def init_channels
      @inbound = Cucub::Channel.vm_inner_inbound
      #@outbound = Cucub::Channel.vm_inner_outbound
    end

    def stop
      Cucub::Channel.shutdown!
      kill_actors
      exit
    end
  end
end
