require 'singleton'
require_relative './vm/configuration'
require 'pan-zmq'

module Cucub
  class VM
    include Singleton

    attr_reader :threaded, :uid, :reporting

    def initialize
      #@dispatcher = Cucub::Dispatcher.instance
      
      @running = true
    end

    def set_uid
      @uid = rand(50)
    end

    def register
      @configuration.classes.each do |class_name|
        Cucub::VM::Driver.instance.register(@uid, class_name)
      end
    end

    def set_reporting
      @reporting = Cucub::Reporting.new(@uid)
      trap("INT") { @reporting.bulk_send }
    end

    def boot(vm_opts={})
      set_uid
      @config_filepath = vm_opts[:config]
      @initializer = vm_opts[:initializer]
      @configuration = Cucub::VM::Configuration.new(@config_filepath)
      @threaded = vm_opts[:threaded].nil? ? true : vm_opts[:threaded]
      register
      set_reporting
    end

    def start!
      
      if @running 
        self.init_classes
        
        $stdout.puts Cucub::ObjectsHub.instance.objects.inspect
        self.init_objects(@initializer) # this will go inside worker instance
        $stdout.puts Cucub::ObjectsHub.instance.objects.inspect

        self.init_reactor
      end
    end

    def init_classes
      @configuration.classes.each do |class_name|
        begin
          const = Kernel.const_get(class_name.capitalize)
          const.send :include, Cucub::Object
        rescue NameError
          $stdout.puts "There is one class defined (#{class_name.capitalize}), that wasn't loaded in the ObjectSpace."
        end
      end
    end

    def init_objects(boot_file)
      boot_file = "./#{boot_file}" unless boot_file.match(/^[\/.]/)
      require boot_file
    end

    def init_reactor
      Cucub::Reactor.instance.run
    end

    def shutdown!
      @running = false
      Cucub::Reactor.instance.stop
    end

    def configuration
      @configuration
    end

    #def address
    #  @address
    #end
  end
  
end
