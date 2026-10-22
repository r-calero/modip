require 'json'
require 'logger'

# Runs the docking jobs stored in the docking_jobs table, one at a time and in
# the order they were queued. Progress and a log line per compound are saved
# in the database, so the web app can show them at any moment and nothing is
# lost if a service restarts: jobs that were running when the docking server
# stopped are queued again and continue from the first compound not yet done.
class DockingQueue
  POLL_SECONDS = 3

  attr_reader :current_job_id

  def initialize(docking_server, logger = Logger.new($stdout))
    @server = docking_server
    @logger = logger
    @current_job_id = nil
  end

  def start
    with_db { DockingJob.where(:status => 'running').update_all(:status => 'queued', :current_cid => nil) }
    @thread = Thread.new do
      loop do
        begin
          job = claim_next_job
          job ? run(job) : sleep(POLL_SECONDS)
        rescue Exception => e
          @logger.error("[docking queue] #{e.class}: #{e.message}\n#{Array(e.backtrace).first(5).join("\n")}")
          sleep POLL_SECONDS
        end
      end
    end
    self
  end

  # Called (through DRb) after the web app marked a job as cancelled: stops
  # the programs of the compound being docked, if it is that job.
  def cancel(job_id)
    @server.kill_running_processes if @current_job_id == job_id.to_i
  end

  private

  def claim_next_job
    with_db do
      job = DockingJob.where(:status => 'queued').order(:id).first
      next nil unless job
      claimed = DockingJob.where(:id => job.id, :status => 'queued').
        update_all(:status => 'running', :started_at => job.started_at || Time.now, :updated_at => Time.now)
      claimed == 1 ? job.reload : nil
    end
  end

  def run(job)
    @current_job_id = job.id
    target = with_db { Target.find_by_id(job.target_id) }
    unless target
      finish(job, 'failed', 'The target no longer exists')
      return
    end
    cids = job.cid_list
    code = Time.now.to_i.to_s
    key = "job-#{job.id}"
    @logger.info("[docking queue] job #{job.id}: #{cids.size} compounds, target #{target.name}")

    cids.drop(job.processed_compounds).each do |cid|
      break unless still_running?(job)
      with_db { DockingJob.where(:id => job.id).update_all(:current_cid => cid, :updated_at => Time.now) }
      success, num_modes, message = dock_one(key, target, cid, code)
      break unless still_running?(job) # cancelled while docking: do not count it
      with_db do
        DockingJobLog.create(:docking_job_id => job.id, :cid => cid, :num_modes => num_modes, :success => success,
                             :message => message.to_s[0, 60000], :created_at => Time.now)
        DockingJob.where(:id => job.id).update_all(
          ["processed_compounds = processed_compounds + 1, failed_compounds = failed_compounds + ?, updated_at = ?",
           success ? 0 : 1, Time.now])
      end
    end

    if still_running?(job)
      job = with_db { job.reload }
      finish(job, 'finished', "#{job.processed_compounds - job.failed_compounds} of #{job.total_compounds} compounds docked")
    end
  ensure
    @current_job_id = nil
    @server.forget_files(key) if key
  end

  # Returns [success, number of poses, log text].
  def dock_one(key, target, cid, code)
    compound = with_db { Compound.find_by_cid(cid) }
    return [false, 0, "Compound #{cid} is not in the database"] unless compound
    @server.prepare_key(key)
    message, num_modes = with_db { @server.make_docking(key, target, compound, code) }
    [num_modes.to_i > 0, num_modes.to_i, message]
  rescue Exception => e
    [false, 0, "Compound #{cid}: #{e.class}: #{e.message}"]
  end

  def still_running?(job)
    with_db { DockingJob.where(:id => job.id).pluck(:status).first } == 'running'
  end

  def finish(job, status, message)
    with_db do
      DockingJob.where(:id => job.id, :status => 'running').
        update_all(:status => status, :message => message, :current_cid => nil, :finished_at => Time.now, :updated_at => Time.now)
    end
    @logger.info("[docking queue] job #{job.id} #{status}: #{message}")
  end

  def with_db
    ActiveRecord::Base.connection_pool.with_connection { yield }
  end
end
