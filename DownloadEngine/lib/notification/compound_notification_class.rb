require 'notification/notification_class'

class CompoundNotificationClass < NotificationClass

	attr_reader :cid, :aid

	# aid: assay being processed (assays can run in parallel).
	def initialize(query_id, cid, event, message, aid = nil)
		super(query_id, event, message)
		@cid = cid
		@aid = aid
	end

end
