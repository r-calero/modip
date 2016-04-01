class Notification < ActiveRecord::Base
  belongs_to :query
  has_one :compound_notification
  has_one :count_notification
  has_one :assay_notification
  has_one :finished_notification
end