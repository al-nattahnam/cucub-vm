require 'singleton'

module Cucub
  class ObjectsHub
    include Singleton

    def initialize
      @objects = []
    end

    def register(object)
      @objects << object
    end

    def objects
      @objects
    end
  end
end
