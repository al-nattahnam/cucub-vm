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

      def proxy_class_for(klass)
        class_name = klass.to_s.underscore
        return false if not Cucub::VM::Configuration.instance.classes.include? class_name
        actions = Cucub::VM::Configuration.instance.actions_for_class(class_name).collect{|action| action.to_sym}
        Cucub::Proxy.new(class_name, actions)

      end

      def send_msg(action, args)
        message = action.to_s
        Cucub::Channel.vm_inner_outbound.send_string(message)
      end
    end
  end
end
