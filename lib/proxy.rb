module Cucub
  class Proxy
    def initialize(class_name, actions)
      @class_name = class_name
      @actions = actions
    end

    def method_missing(method, *args, &block)
      if @actions.include?(method)
        # puts "PROXY: #{method}"
        Cucub::VM::Driver.instance.send_msg(method, args)
      else
        super
      end
    end
  end
end
