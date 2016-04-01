class Query < ActiveRecord::Base
  belongs_to :target
  belongs_to :user
  has_one :schedule
  has_one :cycle, :through => :schedule
  has_many :notifications
  has_one :notification
  has_many :count_notifications, :through => :notifications
  has_many :assay_notifications, :through => :notifications
  has_many :compound_notifications, :through => :notifications
  has_one  :finished_notification, :through => :notification

  #validates :query, :presence => true

  def self.new_query(attributes, initial_time, cycle, schedule)
    @query = new(attributes)
    @query.date = Time.now
    if schedule
      time = Time.local(initial_time[:year], initial_time[:month], initial_time[:day], initial_time[:hour], initial_time[:min])
      @query.schedule = Schedule.new(:cycle => Cycle.find(cycle), :initial_time => time)
    end
    @query
  end

  def date_in_words()
    date ? "#{date.strftime("%B")} #{date.day} of #{date.year}" : "unknown"
  end

end
