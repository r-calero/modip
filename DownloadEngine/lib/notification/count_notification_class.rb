require 'notification/notification_class'

class CountNotificationClass < NotificationClass

	attr_reader :total, :aid

	# Events: AssayCount (assays of the query), CompoundCount (rows of an
	# assay), CompoundProgress (rows done so far) and AssayCompleted.
	# aid: assay the count belongs to (nil for AssayCount).
	def initialize(query_id, total, event, message, aid = nil)
		super(query_id, event, message)
		@total = total
		@aid = aid
	end

end
