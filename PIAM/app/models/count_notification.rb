class CountNotification < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :notification, :total, :element_count
  belongs_to :notification
  belongs_to :query
end