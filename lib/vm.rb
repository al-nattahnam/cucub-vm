require 'singleton'
require './lib/vm/configuration'

module Cucub
  class VM
    include Singleton

    def initialize
      #@dispatcher = Cucub::Dispatcher.instance
    end

    def start!(vm_opts={})
      @config_filepath = vm_opts[:config]
      @configuration = Cucub::VM::Configuration.instance
      #@address = server_opts[:host]
      #@dispatcher.start
    end

    def shutdown!
      #@dispatcher.stop
    end

    def config_filepath
      @config_filepath
    end

    #def address
    #  @address
    #end
  end
  
end
