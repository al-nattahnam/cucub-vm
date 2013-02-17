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
        actions = Cucub::VM.instance.configuration.actions_for_class(class_name).collect{|action| action.to_sym}
        Cucub::Proxy.new(class_name, actions)

      end

      def get_from(klass, action)
        class_name = get_class_name(klass)
        Cucub::VM.instance.configuration.from_for_class_action(class_name, action.to_s)
      end

      def get_respond_to(klass, action)
        class_name = get_class_name(klass)
        Cucub::VM.instance.configuration.respond_to_for_class_action(class_name, action.to_s)
      end

      def get_class_name(klass)
        class_name = klass.to_s.underscore
        return nil if not Cucub::VM.instance.configuration.classes.include? class_name
        class_name
      end

      def send_msg(message)
        #message = action.to_s
        puts message.inspect
        Cucub::Channel.vm_inner_outbound.send_string(message.serialize)
      end

      def register(uid, klass)
        # TODO FIX armar mensajes para boot entre vm y server
        $stdout.puts "Registering: #{uid} #{klass}"
        # Cucub::Channel.vm_inner_outbound.send_string("register #{uid} #{klass}")
      end
    end
  end
end
