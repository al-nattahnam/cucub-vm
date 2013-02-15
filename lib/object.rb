module Cucub
  module Object
    def self.included(base)
      base.extend(Cucub::Object::ClassMethods)
    end

    def uuid
      uuid = hash
      uuid = -uuid if uuid < 0
      uuid.to_s(35)
    end

    def reference
      Cucub::Reference.new(:object_uuid => uuid, :class_name => Cucub::VM::Driver.instance.get_class_name(self.class))
    end

    module ClassMethods
      def new(*args, &block)
        obj = super
        Cucub::ObjectsHub.instance.register(obj)
        obj
      end

      def reference
        Cucub::Reference.new(:class_name => Cucub::VM::Driver.instance.get_class_name(self))
      end

      def proxy(options={})
        proxy = Cucub::VM::Driver.instance.proxy_for_class(self)
        proxy.default_respond_to=(options[:respond_to].reference) if options.has_key?(:respond_to)
        proxy
      end

      def instance(*args, &block)
        obj = super
        Cucub::ObjectsHub.instance.register(obj)
        obj
      end
    end
  end
end
