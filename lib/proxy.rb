module Cucub
  class Proxy
    def initialize(class_name, actions)
      @class_name = class_name
      @actions = actions
    end

    def uuid
      uuid = hash
      uuid = -uuid if uuid < 0
      uuid.to_s(35)
    end

    def default_respond_to=(reference)
      @default_respond_to = reference
    end

    def default_respond_to
      @default_respond_to
    end

    def reference
      Cucub::Reference.new(:class_name => Cucub::VM::Driver.instance.get_class_name(@class_name))
    end

    def method_missing(method, args={}, &block)
      if @actions.include?(method)
        # puts "PROXY: #{method}"

        ### Build message START
        ## Build from START
        from = Cucub::VM::Driver.instance.get_from(@class_name, method) if not args.has_key?(:from)
        from = Cucub::Reference.new(:class_name => from)
        ## Build from END
        ## Build respond_to START

        overriden_respond_to = args.delete(:respond_to).reference rescue nil
        overriden_respond_to ||= default_respond_to

        # TODO Remains the validation of the overriden respond_to values :)
        if not overriden_respond_to
          respond_to = Cucub::VM::Driver.instance.get_respond_to(@class_name, method) if not args.has_key?(:respond_to)

          instance_specific, object_uuid = respond_to.is_instance_specific?
          class_specific, class_name = respond_to.is_class_specific?
          zone_specific, zone = respond_to.is_zone_specific?
        
          respond_to = Cucub::Reference.new(:object_uuid => object_uuid, :class_name => class_name)
        else
          respond_to = overriden_respond_to
        end

        ## Build respond_to END

        message = Cucub::Message.new("from" => from, "to" => self.reference, "respond_to" => respond_to, "action" => method, "additionals" => args)
        # TODO set Cucub::Proxy#from
        # TODO set Cucub::Proxy#respond_to
        # TODO implement same configuration style as respond_to on from field.
        # TODO move this to a class in charge
        ### Build message END

        Cucub::VM::Driver.instance.send_msg(message)
      else
        super
      end
    end
  end
end
