class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

module Cucub
  class VM
    class Driver
      include Singleton

      def proxy_for_class(klass)
        class_name = get_class_name(klass)
        actions = Cucub::VM::Configuration.instance.actions_for_class(class_name).collect{|action| action.to_sym}
        Cucub::Proxy.new(class_name, actions)

      end

      def get_from(klass, action)
        class_name = get_class_name(klass)
        Cucub::VM::Configuration.instance.from_for_class_action(class_name, action.to_s)
      end

      def get_respond_to(klass, action)
        class_name = get_class_name(klass)
        Cucub::VM::Configuration.instance.respond_to_for_class_action(class_name, action.to_s)
      end

      def get_class_name(klass)
        class_name = klass.to_s.underscore
        return nil if not Cucub::VM::Configuration.instance.classes.include? class_name
        class_name
      end

      def send_msg(message)
        #message = action.to_s
        puts message.inspect
        Cucub::Channel.vm_inner_outbound.send_string(message.serialize)
      end
    end
  end
end
