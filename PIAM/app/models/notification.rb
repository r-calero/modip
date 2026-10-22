class Notification < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :message, :query_id, :event
  belongs_to :query
  has_one :compound_notification
  has_one :count_notification
  has_one :assay_notification
  has_one :finished_notification
end