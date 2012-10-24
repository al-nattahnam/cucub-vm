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
      self.init_classes
      
      $stdout.puts Cucub::ObjectsHub.instance.objects.inspect
      self.init_objects(vm_opts[:initializer]) # this will go inside worker instance
      $stdout.puts Cucub::ObjectsHub.instance.objects.inspect
      EM.run do
        $stdout.puts "inside reactor"
      end
    end

    def init_classes
      Cucub::VM::Configuration.instance.classes.each do |class_name|
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

    def shutdown!
      EM.stop
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
