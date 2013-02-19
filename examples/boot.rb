# Run it on root dir with this command:
# ruby bin/cucub-vm.rb start examples/boot.rb -c examples/protocol.ini -i examples/initializer.rb

class Core
  def state(i=1)
    i = i.to_f
    puts "--ack--"
    sleep(i)
    puts "Hola! #{i}"
  end
end

# TODO try to supress this requirement
class Engine
end
