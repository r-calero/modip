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


  def never_run
	if schedule
		schedule.initial_time > Time.now
	else
		true
	end
  end
  
  def next_run
	first_run = schedule.initial_time
	now = Time.now
	dif = now - first_run
	run_times = (dif / schedule.cycle.time).to_i
	next_run = first_run + (schedule.cycle.time * (run_times + 1))
	next_run
  end
  
  def date_in_words()
    date ? "#{date.strftime("%B")} #{date.day} of #{date.year}" : "unknown"
  end
  
  def sec2dhms(secs)
    time = secs.round          # Get rid of microseconds
    sec = time % 60            # Extract seconds
    time /= 60                 # Get rid of seconds
    mins = time % 60           # Extract minutes
    time /= 60                 # Get rid of minutes
    hrs = time % 24            # Extract hours
    time /= 24                 # Get rid of hours
    days = time                # Days (final remainder)
    {:days => days, :hours => hrs, :minutes => mins, :secs => sec}     # Return hash {d,h,m,s}
  end

end
