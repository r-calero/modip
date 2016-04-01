class CompoundNotificationType < ActiveRecord::Base
  has_one :compound_notification
  
  def is_compound_inserted 
     self.name == "CompoundInserted"
  end
end
