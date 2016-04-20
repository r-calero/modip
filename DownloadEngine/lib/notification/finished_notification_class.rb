require 'notification/notification_class'

class FinishedNotificationClass < NotificationClass

	attr_reader :time
	
	def initialize(query_id, time, message, event = 'Finished')
		super(query_id, event, message)
		@time = time
	end

end

