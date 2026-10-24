class CompoundNotificationType < ActiveRecord::Base
  INSERTED = %w(CompoundInserted CompoundQueued3D)

  has_one :compound_notification

  # Compound stored by the download (in 3D, or in 2D and queued for its 3D
  # conversion): it is docked when the download ends.
  def is_compound_inserted
    INSERTED.include?(self.name)
  end
end
