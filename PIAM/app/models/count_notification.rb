class CountNotification < ActiveRecord::Base
  belongs_to :notification
  belongs_to :query
end