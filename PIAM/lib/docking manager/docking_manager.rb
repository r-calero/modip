require "drb"
require 'rufus/scheduler'

# Web side of the docking server (Server/docking_server.rb, reached via DRb).
#
# Docking requests are stored as DockingJob rows and run by the docking
# server queue; this class only enqueues/cancels them, sends the e-mails of
# finished jobs and forwards file operations (targets, receptors, results).
class DockingManager

  def initialize()
    @server = DRbObject.new(nil, ENV['MODIP_DOCKING_DRB_URI'] || "druby://localhost:1997")
    @scheduler = Rufus::Scheduler.start_new
    @scheduler.every('1m') { send_finished_job_emails }
  end

  # ---- docking jobs ----

  def enqueue(user, target, cids, notify_by_email = false)
    DockingJob.enqueue(user, target, cids, notify_by_email)
  end

  def cancel(job)
    cancelled = job.cancel!
    begin
      @server.cancel_job(job.id) if cancelled
    rescue DRb::DRbError => e
      Rails.logger.warn("[docking] could not reach the docking server to stop job #{job.id}: #{e.message}")
    end
    cancelled
  end

  # E-mail with the best results of each finished job that asked for it.
  def send_finished_job_emails
    ActiveRecord::Base.connection_pool.with_connection do
      DockingJob.where(:status => 'finished', :notify_by_email => true, :notified_at => nil).includes(:user, :target).each do |job|
        begin
          Notifier.docking_job_finished(job, best_results(job)).deliver if job.user && job.user.name != User::DefaultUser
        rescue StandardError, Timeout::Error => e
          Rails.logger.error("[docking] could not send the e-mail of job #{job.id}: #{e.class}: #{e.message}")
        ensure
          DockingJob.where(:id => job.id).update_all(:notified_at => Time.now)
        end
      end
    end
  end

  # [[cid, receptor type, best energy], ...] of a job, best first.
  def best_results(job, limit = 20)
    ReceptorCompound.joins(:compound, :prepare_receptor => :receptor_type).
      where('compounds.cid' => job.cid_list, 'prepare_receptors.target_id' => job.target_id).
      group('compounds.cid, receptor_types.name').
      select('compounds.cid AS cid, receptor_types.name AS receptor, MIN(receptor_compounds.value) AS best').
      order('best').limit(limit).
      map { |r| [r.cid, r.receptor, r.best.to_f] }
  rescue StandardError
    []
  end

  # ---- files on the docking server ----

  def get_resource(resource)
    @server.get_resource(resource)
  end

  def upload_file(target, file, data)
    @server.upload_file(target, file, data)
  end

  def prepare_receptor_file(pdb_path)
    @server.prepare_receptor_file(pdb_path)
  end

  def archive_files(paths, folder_name)
    @server.archive_files(paths, folder_name)
  end

  def create_target_dir(target_name)
    @server.create_target_dir(target_name)
  end

  # Deletes a receptor (or target folder) and, optionally, its docking outputs.
  def delete_receptor(receptor_path, conformers = [])
    conformers.each do |conformer|
      path = conformer.respond_to?(:path) ? conformer.path : conformer
      @server.delete_receptor(path) if path
    end
    @server.delete_receptor(receptor_path)
  end

end
