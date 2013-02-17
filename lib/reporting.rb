module Cucub
  class Reporting
    # include Singleton
  
    def initialize(vm_uid)
      @vm_uid = vm_uid
      @messages = []
      @last_send = Time.now
      @max_elapsed_time = 1
    end
    
    #def set_vm_uid=(vm_uid)
    #  @vm_uid = vm_uid
    #end
  
    def task_done(msg)
      # Remains:
      #  send all when no activity is registered
      #  differentiate classes and uids in the messages
      #  
      @messages << msg
      if (Time.now - @last_send) > @max_elapsed_time
        self.bulk_send
      end
    end
  
    def bulk_send
      puts "ready #{@vm_uid} engine #{@messages.join(",")}"
      Cucub::Channel.vm_inner_outbound.send_string "ready #{@vm_uid} engine #{@messages.join(",")}"
      @last_send = Time.now
      @messages = []
    end
  end
end
