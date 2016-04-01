class UserReadout < ActiveRecord::Base
   belongs_to :column_description
   belongs_to :assay_compound
end