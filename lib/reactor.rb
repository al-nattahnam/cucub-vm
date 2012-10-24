require 'singleton'

module Cucub
  class Reactor
    include Singleton

    def run
      EM.epoll
      EM.run do
        $stdout.puts "inside reactor"
        self.init_channels
        #Cucub::Channel.channels.each {|channel|
        #  $stdout.puts channel.inspect
        #}
      end
    end

    def init_channels
      @inbound = Cucub::Channel.vm_inner_inbound
      @outbound = Cucub::Channel.vm_inner_outbound
    end

    def stop
      EM.stop
    end
  end
end
