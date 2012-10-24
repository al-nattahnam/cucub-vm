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

    module ClassMethods
      def new(*args, &block)
        obj = super
        Cucub::ObjectsHub.instance.register(obj)
        obj
      end

      def instance(*args, &block)
        obj = super
        Cucub::ObjectsHub.instance.register(obj)
        obj
      end
    end
  end
end
