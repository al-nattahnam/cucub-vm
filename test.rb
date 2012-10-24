require './lib/object'
require './lib/objects_hub'

class Bla
  def initialize(test)
    @test = test
  end

  def test
    @test
  end
end

class Blo
  def initialize(test)
    @test = test
  end

  def test
    @test
  end
end

# We need to add an initializer method for the Cucub-VM,
# so that each class defined in the protocol will be taked into account for Cucub messages
# after including (read it as: ".send :include") Cucub::Object behavior.
["engine", "bla"].each {|class_name|
  begin
    const = Kernel.const_get(class_name.capitalize)
    const.send :include, Cucub::Object
  rescue NameError
  end
}

puts "ObjectsHub instances: #{Cucub::ObjectsHub.instance.objects.inspect}"

b = Bla.new("123")
c = Bla.new("123")
puts "ObjectsHub instances: #{Cucub::ObjectsHub.instance.objects.inspect}"
puts "b.uuid: #{b.uuid}"
puts "c.uuid: #{c.uuid}"
