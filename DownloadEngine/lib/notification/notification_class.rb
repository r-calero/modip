class NotificationClass
	
	attr_reader :query_id, :message, :event
	
	def initialize(query_id, event, message = nil)
	  @query_id = query_id
	  @event = event
		@message = message
	end
end
