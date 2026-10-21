require_relative '../notification/user_observer'

class DockingObserver < UserObserver

  def initialize(id, notify_server, compounds_count)
    super(id, notify_server)
    @finish_notification = 0
    @total = compounds_count
  end

  def process
    @process
  end

  def total
    @total
  end
  
  def update(*notifications)
    notifications.each do |notification|
      if notification.key == @id
        @last_id += 1
        if notification.event != "Finished"
			hash = {:message => notification.message, :num_modes => notification.num_modes}
			@notifications << UserNotification.new(notification.event, hash, @last_id)
		elsif notification.event == "Finished"
			@finish_notification += 1
			if @last_id - @finish_notification == @total # end of the docking (the other Finished events come from splitting the compound set)
				hash = {:message => notification.message, :num_modes => notification.num_modes}
				@notifications << UserNotification.new(notification.event, hash, @last_id)
				stop_listen() 
			end
        end
      end
    end
  end

end
