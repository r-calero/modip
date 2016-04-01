class AssayNotification < ActiveRecord::Base
  belongs_to :notification
  belongs_to :assay_notification_type
  belongs_to :query

  def assay
    Assay.find_by_aid(aid)
  end


end