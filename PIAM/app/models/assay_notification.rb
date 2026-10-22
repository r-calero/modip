class AssayNotification < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :notification, :aid, :assay_notification_type
  belongs_to :notification
  belongs_to :assay_notification_type
  belongs_to :query

  def assay
    Assay.find_by_aid(aid)
  end


end