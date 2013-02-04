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
        @classes = nil
      end

      def actions_for_class(class_name)
        obj_spec = @specification_set[class_name]
        obj_spec.action_specifications.collect(&:action_name)
      end

      def classes
        # lazy load array of classes
        return @classes if @classes
        classes = @specification_set.classes
        @classes = classes
      end
    end
  end
end
