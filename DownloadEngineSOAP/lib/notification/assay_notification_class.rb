require 'notification/notification_class'

class AssayNotificationClass < NotificationClass
	
	attr_reader :aid
	
	def initialize(query_id, aid, event, message)
		super(query_id, event, message)
		@aid = aid
	end
	
end
