require "drb"
require 'rufus/scheduler'
require_relative 'download_observer'
require_relative '../notification/notification_manager'

class QueryManager < NotificationManager

  attr_reader :scheduler
  # provisional
  attr_reader :download_server

  def initialize()
    @download_server = DRbObject.new(nil, ENV['MODIP_DOWNLOAD_DRB_URI'] || "druby://localhost:1989")
    @downloads_observers = {}
    @scheduler = Rufus::Scheduler.start_new
    Query.all.each do |query|
      @downloads_observers[query.id] = DownloadObserver.new(query.id, @download_server)
      schedule_query(query) if query.schedule
      mark_interrupted(query) if query.last_status == 'running'
    end

  end

  def start_download(query)
    @downloads_observers[query.id] ||= DownloadObserver.new(query.id, @download_server)
    @downloads_observers[query.id].start
    if @download_server.start_download(query.id, query.query, query.target_id, query.outcome_assay_filter, query.min_date, query.max_date)
      query.run_started!
      true
    else
      @downloads_observers[query.id].stop
      false
    end

  end

  def stop_download(query)
    if @download_server.stop_download(query.id)
      @downloads_observers[query.id].stop
      query.run_stopped!
      true
    else
      false
    end

  end

  def destroy(channel)
    @download_server.destroy(channel)
    observer = @downloads_observers[channel]
    if observer
      observer.stop
      @downloads_observers.delete(channel)
    end

  end

  def downloading(channel)
    @download_server.downloading(channel)
  end

  # Progress of a query download for the progress bar (see DownloadServer#progress):
  # {status: running|complete|stopped|idle, percent, total_assays, completed_assays, ...}
  def get_progress(query_id)
    info = begin
      @download_server.progress(query_id)
    rescue DRb::DRbError
      nil
    end
    conversions = ConversionJob.summary_for_query(query_id)
    query = Query.find_by_id(query_id)
    return info.merge('status' => 'running', 'running' => true, 'conversions' => conversions, 'last_run' => last_run(query)) if info
    finished = Notification.where(:query_id => query_id, :event => %w(Finished Stop)).order('id DESC').first
    status = finished ? (finished.event == 'Stop' ? 'stopped' : 'complete') : 'idle'
    mark_interrupted(query) if query && !finished && query.last_status == 'running' &&
                               query.last_started_at && query.last_started_at < Time.now - 60
    { 'status' => status, 'running' => false, 'percent' => (status == 'complete' ? 100.0 : 0.0),
      'message' => finished && finished.message, 'conversions' => conversions, 'last_run' => last_run(query && query.reload) }
  end

  # Result of the last run, for the queries page.
  def last_run(query)
    return nil unless query
    { 'status' => query.last_status, 'summary' => query.run_summary_text,
      'finished_at' => query.last_finished_at && query.last_finished_at.strftime('%Y-%m-%d %H:%M') }
  end

  # A run marked as running that the download server no longer runs (it was
  # restarted, for example).
  def mark_interrupted(query)
    running = begin
      @download_server.downloading(query.id)
    rescue DRb::DRbError
      return
    end
    query.run_interrupted! unless running
  end

  def get_process(channel)
    observer = @downloads_observers[channel]
    [observer.process_assays, observer.total_assays, observer.process_compounds, observer.total_compounds]
  end

  def get_notification(channel, last_event_id)
    observer = @downloads_observers[channel]
    checkout_notification(observer, channel, last_event_id)
  end

  def schedule_query(query)
    start_time = query.schedule.initial_time
    @scheduler.every Rufus.to_duration_string(query.cycle.time, :months => true), :first_at => query.never_run ? start_time : query.next_run , :timeout => Rufus.to_duration_string(query.cycle.time - 600), :tags => query.id do |job|
      begin
        start_download(query)
      rescue Rufus::Scheduler::TimeOutError
        stop_download(query)
      end
    end

  end

  def unscheduled_query(query)
    job = @scheduler.find_by_tag(query.id).first
    stop_download(query) if job.running?
    job.unschedule
  end

  def update_schedule_query(query)
    unscheduled_query(query)
    schedule_query(query)
  end

  def data_download(path)
	@download_server.data_download(path)
  end

end
