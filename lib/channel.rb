module Cucub
  class Channel
    def initialize(kind)
      @kind = kind
      case @kind
        when :vm_inner_inbound
          vm_inner_inbound_start
        when :vm_inner_outbound
          vm_inner_outbound_start
      end
    end

    def self.vm_inner_inbound
      return @@vm_inner_inbound if defined?(@@vm_inner_inbound) and @@vm_inner_inbound.is_a? Cucub::Channel

      @@vm_inner_inbound = Cucub::Channel.new(:vm_inner_inbound)
    end

    def self.vm_inner_outbound
      return @@vm_inner_outbound if defined?(@@vm_inner_outbound) and @@vm_inner_outbound.is_a? Cucub::Channel

      @@vm_inner_outbound = Cucub::Channel.new(:vm_inner_outbound)
    end

    def self.channels
      channels = []
      channels << @@vm_inner_inbound if defined?(@@vm_inner_inbound)
      channels << @@vm_inner_outbound if defined?(@@vm_inner_outbound)
      channels
    end

    def vm_inner_inbound_start
      # a ZMQ PUSH-PULL socket which connects to the local server as a 'puller', so workers can consume messages.

      # It works by connecting to an IPC socket. In a future, it might be considered to
      #   enable tcp communication, so workers can be outside the local server.

      $stdout.puts "Connecting to the Inner Inbound (PULL) socket"
      @socket = MaZMQ::Pull.new
      @socket.connect :ipc, "/tmp/cucub-inner-inbound.sock"
    end

    def vm_inner_outbound_start
      # a ZMQ PUSH-PULL socket which connects to the local server as a 'pusher', so workers can push their messages.
      
      # It works by connecting to an IPC socket. In a future, it might be considered to
      #   enable tcp communication, so workers can be outside the local server.

      $stdout.puts "Connecting to the Inner Inbound (PUSH) socket"
      @socket = MaZMQ::Push.new
      @socket.connect :ipc, "/tmp/cucub-inner-outbound.sock"
    end

    def recv_string
      @socket.recv_string(ZMQ::NOBLOCK)
    end

    def send_string(msg)
      @socket.send_string(msg)
    end

    def socket
      @socket
    end

    def close
      $stdout.puts "Closing #{@kind} socket."
      @socket.close
    end

    def self.shutdown!
      @@vm_inner_inbound.close if defined?(@@vm_inner_inbound)
      @@vm_inner_outbound.close if defined?(@@vm_inner_outbound)

      MaZMQ.terminate
    end

  end
end
