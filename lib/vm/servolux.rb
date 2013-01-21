require 'servolux'
require 'logger'

module Cucub
  class VM
    class Servolux < Servolux::Server
      attr_accessor :vm_opts
      
      def run
        @vm_opts[:threaded] = false
        Cucub::VM.instance.start!(@vm_opts)
        Process.waitall
      end

      def prefork
      end

      def before_stopping
        Cucub::VM.instance.shutdown!
      end
    end
  end
end

# TODO implement Servolux running as a Daemon
# daemon = Servolux::Daemon.new(:server => server)
# daemon.startup
# daemon.shutdown
#Cucub.start!('10.0.0.4')
