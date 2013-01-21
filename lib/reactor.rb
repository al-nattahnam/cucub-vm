require 'singleton'

require 'fiber'

require "logger"

module Cucub
  class Reactor
    include Singleton

    attr_accessor :logger

    def initialize
      if not Cucub::VM.instance.threaded
        self.logger = Logger.new($stderr)
        self.logger.level = Logger::DEBUG
        
        self.class.send(:include, ::Servolux::Threaded)
      end
      
      @actors = []

      @reactor_thread = nil

      @state = :idle

      trap("INT") { self.stop }

      if not Cucub::VM.instance.threaded
      start
      join
      end
      self
    end

    def run
      if @state == :idle

        $stdout.puts "idle"
      
        plug_actors
        init_channels

        $stdout.puts "receiving"
        # This should be on inbound creation method
        @inbound.on_receive { |msg|
          $stdout.puts "received: #{msg.inspect}"
          #msg[msg.size - 1] = unwrap_message(msg) #.last)
         
          msg = unwrap_message(msg)
          #@actors.first.wire(msg)

          @actors.first.process(msg)
          $stdout.puts "\n"
        }

        @state = :preparing_container
      end
      if @state == :preparing_container
        $stdout.puts "preparing container"
        container_prepare
      end

      # container.resume

        begin
          $stdout.puts "running container"
          container_run
          # @reactor_thread.join
        rescue Exception => e
          puts "handled exception"
        end

    end

    def plug_actors
      Cucub::ObjectsHub.instance.objects.each do |object|
        actor = Cucub::Actor.new(object)
        plug_actor(actor)
      end
    end

    def container_prepare
      #@reactor_fiber = Fiber.new {
      @reactor_thread ||= Thread.new {

        begin

          # worker is going to be a Class, fibered-aware, which can receive messages
          # relay(@worker)

          $stdout.puts "prepared to receive."

          while @state != :stopped
            case @state
              when :preparing_container
                Thread.stop
              when :running
                PanZMQ::Poller.instance.poll
            end
          end

        rescue Exception => e
          puts "exception: #{e.exception}"
        end
      }
    end

    def container_run
      @state = :running
      @reactor_thread.run
      # @reactor_thread.join
    end

    def container_stop
      @state = :stopped
      # @reactor_thread.raise "terminated!"
    end

    def unwrap_message(message)
      unserialized = Cucub::Message.parse(message)
      unserialized
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
      @state = :stopped
      Cucub::Channel.shutdown!
      kill_actors
      exit
    end
  end
end
