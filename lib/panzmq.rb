require 'ffi-rzmq'

module PanZMQ
  @@context = nil
  def self.context
    # Como MaZMQ estaria funcionando siempre en EM, el proceso en el cual corre seria siempre unico, y por esa razon (repasando http://zguide.zeromq.org/page:all#Getting-the-Context-Right), usamos un unico Contexto en toda la aplicacion. Y el usuario no tiene que instanciar uno.
    @@context ||= ZMQ::Context.new
    @@context
  end
  
  def self.terminate
    @@context.terminate if @@context
  end
  
  class Pull
    def initialize
      @socket = PanZMQ.context.socket ZMQ::PULL
      #@socket.setsockopt(ZMQ::LINGER, 0)
      @messages = []
      @alive = true
    end

    def kill
      @alive = false
    end

    def connect(params)
      @socket.connect params
    end

    def bind(params)
      @socket.bind params
    end

    def receive(&block)
      while (@socket.recv_strings(@messages) == 0 and @alive)
        yield @messages
      end
    end

    def close
      kill
      @socket.close
    end
  end

  class Push
    def initialize
      @socket = PanZMQ.context.socket ZMQ::PUSH
      #@socket.setsockopt(ZMQ::LINGER, 0)
    end

    def connect(params)
      @socket.connect params
    end

    def send_string(message)
      @socket.send_string(message)
    end

    def bind(params)
      @socket.bind params
    end

    def close
      @socket.close
    end
  end
end
