require 'json'

class Query < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :query, :target_id, :outcome_assay_filter, :min_date, :max_date
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

  #--------------------------------------- result of the last run ----------------------------------------
  # last_status: never | running | complete | partial | failed | stopped | interrupted
  RUN_STATUSES = %w(never running complete partial failed stopped interrupted)

  def run_started!
    self.class.where(:id => id).update_all(:last_status => 'running', :last_started_at => Time.now,
                                           :last_finished_at => nil, :last_summary => nil)
  end

  # event: "Finished" (the download ended) or "Stop" (it ended with an error).
  def run_finished!(event)
    summary = count_run_results
    status = if event == 'Stop' then 'failed'
             elsif summary['assays_failed'] + summary['compounds_failed'] > 0 then 'partial'
             else 'complete'
             end
    record_run_end(status, summary)
  end

  def run_stopped!
    record_run_end('stopped', count_run_results)
  end

  def run_interrupted!
    record_run_end('interrupted', count_run_results)
  end

  def run_summary
    JSON.parse(last_summary.to_s)
  rescue JSON::ParserError
    {}
  end

  # "assays: 4 new, 1 already stored · compounds: 183 new (16 queued for 3D), 2 discarded"
  def run_summary_text
    s = run_summary
    return '' if s.empty?
    assays = ["#{s['assays_new'].to_i} new"]
    assays << "#{s['assays_existing']} already stored" if s['assays_existing'].to_i > 0
    assays << "#{s['assays_failed']} failed" if s['assays_failed'].to_i > 0
    compounds = ["#{s['compounds_new'].to_i} new" + (s['compounds_queued_3d'].to_i > 0 ? " (#{s['compounds_queued_3d']} queued for 3D)" : '')]
    compounds << "#{s['compounds_existing']} already stored" if s['compounds_existing'].to_i > 0
    compounds << "#{s['compounds_discarded']} discarded" if s['compounds_discarded'].to_i > 0
    compounds << "#{s['compounds_failed']} failed" if s['compounds_failed'].to_i > 0
    "assays: #{assays.join(', ')} \u00b7 compounds: #{compounds.join(', ')}"
  end

  private

  def record_run_end(status, summary)
    self.class.where(:id => id).update_all(:last_status => status, :last_finished_at => Time.now,
                                           :last_summary => JSON.generate(summary))
  end

  # Counts of the notifications of the last run (they are deleted when a run starts).
  def count_run_results
    counts = Notification.where(:query_id => id).group(:event).count
    discarded = Notification.where(:query_id => id, :event => 'CompoundFailed').where("message LIKE '%discarded because%'").count
    {
      'assays_new' => counts['AssayInserted'].to_i,
      'assays_existing' => counts['AssayProcessed'].to_i,
      'assays_failed' => counts['AssayFailed'].to_i,
      'compounds_new' => counts['CompoundInserted'].to_i + counts['CompoundQueued3D'].to_i,
      'compounds_queued_3d' => counts['CompoundQueued3D'].to_i,
      'compounds_existing' => counts['CompoundProcessed'].to_i,
      'compounds_discarded' => discarded,
      'compounds_failed' => counts['CompoundFailed'].to_i - discarded
    }
  end
end
