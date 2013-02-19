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
        # TODO Missing:
        #   When a new VM registers, if there are any messages that may be sent to i, start doing
        #   Capture when the process is being shutdown and send a signal to the 'brain' to remove this worker from the list
        #   When no activity is registered from a VM, disable it and mark the failure
        #   Also add message Id and the other type of messages into the Message class (Protocol gem)
        
        $stdout.puts "Registering: #{uid} #{klass}"
        
        # TODO organize VM and Server refs
        # TODO cambiar object_uuid a uuid
        vm_ref = Cucub::Reference.new(:object_uuid => uid, :layer => :vm)
        server_ref = Cucub::Reference.new(:layer => :server)

        message = Cucub::Message.new("from" => vm_ref, "to" => server_ref, "action" => "register", "additionals" => [uid, klass])
        puts message.inspect

        Cucub::Channel.vm_inner_outbound.send_string message.serialize
      end
    end
  end
end
