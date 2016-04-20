require 'notification/notification_class'

class CompoundNotificationClass < NotificationClass

	attr_reader :cid
	
	def initialize(query_id, cid, event, message)
		super(query_id, event, message)
		@cid = cid
	end
	
end
