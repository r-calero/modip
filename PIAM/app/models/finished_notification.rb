class FinishedNotification < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :notification, :time
  belongs_to :notification
  belongs_to :query
end