require "drb"

class UserObserver
  include DRbUndumped

  attr_reader :notifications, :history, :listen

  def initialize(id, notify_server)
    @id = id
    @notify_server = notify_server
    @notifications = []
    @history = []
    @listen = false
    @last_id = 0
    @process = 0
  end

  class UserNotification

    attr_accessor :id, :event, :message

    def initialize(event = nil, message = nil, id = nil)
      @id = id
      @event = event
      @message = message
    end
  end

  def start()
    @notify_server.add_observer(self)   
    @listen = true
    @notifications = []
    @history = []
    @process = 0
    @last_id = 0
  end

  def stop()
    if @listen
      stop_listen()
    end
    
  end
  
  def stop_listen()
	@notify_server.delete_observer(self)
    @listen = false
  end

  def update(*notifications)
    notifications.each do |notification|
      if notification.key == @id
        hash = {:message => notification.message, :num_modes => notification.num_modes}
        @last_id += 1
        @notifications << UserNotification.new(notification.event, hash, @last_id)
        if notification.event == "Finished"
        	stop_listen()
        end
        
      end
    end
  end

  def notification?
    @notifications.any?
  end

  def get_notification
    @process += 1
    @notifications.delete_at(0)
  end

  def push(notification)
    @precess -= 1
    @notifications.insert(0, notification)
  end

  def push_history(notification)
    @history.insert(0, notification)
  end


end
