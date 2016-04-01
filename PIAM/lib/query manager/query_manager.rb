require "drb"
require 'rufus/scheduler'
require_relative 'download_observer'
require_relative '../notification/notification_manager'

class QueryManager < NotificationManager

  attr_reader :scheduler
  # provisional
  attr_reader :download_server

  def initialize()
    @download_server = DRbObject.new(nil, "druby://localhost:1989")
    @downloads_observers = {}
    @scheduler = Rufus::Scheduler.start_new
    Query.all.each do |query|
      @downloads_observers[query.id] = DownloadObserver.new(query.id, @download_server)
      schedule_query(query) if query.schedule
    end

  end

  def start_download(query)
    @downloads_observers[query.id] ||= DownloadObserver.new(query.id, @download_server)
    @downloads_observers[query.id].start
    if @download_server.start_download(query.id, query.query, query.target_id, query.outcome_assay_filter, query.min_date, query.max_date)
      true
    else
      @downloads_observers[query.id].stop
      false
    end

  end

  def stop_download(query)
    if @download_server.stop_download(query.id)
      @downloads_observers[query.id].stop
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
