require 'notification/notification_class'

class CountNotificationClass < NotificationClass

	attr_reader :total
	
	def initialize(query_id, total, event,  message)
		super(query_id, event, message)
		@total = total
	end

end

