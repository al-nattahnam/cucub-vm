require 'singleton'

module Cucub
  class VM
    class Configuration
      #include Singleton

      def initialize(config_filepath)
        @loader = Cucub::Protocol::Loader.new
        set_config_file(config_filepath)
        reload
      end

      def set_config_file(config_filepath)
        @loader.set_path(config_filepath)
      end

      def reload
        @specification_set = @loader.parse
        @classes = nil
      end

      def actions_for_class(class_name)
        obj_spec = @specification_set[class_name]
        obj_spec.action_specifications.collect(&:action_name)
      end

      def respond_to_for_class_action(class_name, action)
        @specification_set[class_name].action_specifications.select {|spec| spec.action_name == action }.first.respond_to
      end

      def from_for_class_action(class_name, action)
        @specification_set[class_name].action_specifications.select {|spec| spec.action_name == action }.first.from
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
