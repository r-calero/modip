class CompoundNotification < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :notification, :cid, :compound_notification_type
  belongs_to :notification
  belongs_to :compound_notification_type
  belongs_to :query

  def compound
    Compound.find_by_cid(cid)
  end

end