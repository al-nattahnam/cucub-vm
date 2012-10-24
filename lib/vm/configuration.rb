require 'singleton'

module Cucub
  class VM
    class Configuration
      include Singleton

      def initialize
        @loader = Cucub::Protocol::Loader.instance
        set_config_file
        reload
      end

      def set_config_file
        @loader.set_path(Cucub::VM.instance.config_filepath)
      end

      def reload
        @specification_set = @loader.parse
        $stdout.puts self.classes.inspect
        @uses = nil
      end

      def classes
        # lazy load array of classes
        return @classes if @classes
        #uses = []
        #uses << "box" if @specification_set.uses_box
        #uses << "mailbox" if @specification_set.uses_mailbox
        #uses << "board" if @specification_set.uses_board
        @uses = @specification_set.classes
      end
    end
  end
end
