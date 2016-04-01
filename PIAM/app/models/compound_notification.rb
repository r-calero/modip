class CompoundNotification < ActiveRecord::Base
  belongs_to :notification
  belongs_to :compound_notification_type
  belongs_to :query

  def compound
    Compound.find_by_cid(cid)
  end

end