require 'json'

# A docking request: a list of compounds docked against every receptor of a
# target. Jobs are queued here by the web app and run one at a time by the
# docking server (Server/docking_queue.rb), which updates the progress.
class DockingJob < ActiveRecord::Base
  STATUSES = %w(queued running finished failed cancelled)
  ACTIVE = %w(queued running)

  belongs_to :user
  belongs_to :target
  has_many :docking_job_logs, :order => 'id'

  attr_accessible # nothing is mass-assignable

  scope :active, where(:status => ACTIVE)
  scope :recent, order('id DESC')

  def self.enqueue(user, target, cid_list, notify_by_email = false)
    cid_list = cid_list.map { |c| c.to_s.strip }.reject { |c| c.empty? }.uniq
    job = new
    job.user_id = user.id
    job.target_id = target.id
    job.status = 'queued'
    job.cids = JSON.generate(cid_list)
    job.total_compounds = cid_list.size
    job.notify_by_email = notify_by_email
    job.save!
    job
  end

  def cid_list
    JSON.parse(cids.to_s)
  rescue JSON::ParserError
    []
  end

  def active?
    ACTIVE.include?(status)
  end

  def percent
    return (status == 'finished' ? 100.0 : 0.0) if total_compounds.to_i == 0
    [(processed_compounds.to_f * 100 / total_compounds).round(1), 100.0].min
  end

  # Marks the job as cancelled if it is still queued or running (atomic).
  def cancel!
    now = Time.now
    self.class.where(:id => id, :status => ACTIVE).
      update_all(:status => 'cancelled', :finished_at => now, :updated_at => now, :message => 'Cancelled by the user') == 1
  end

  # Progress for the job page; logs newer than after_log_id only.
  def progress(after_log_id = 0)
    logs = docking_job_logs.where('id > ?', after_log_id.to_i).limit(200).to_a
    {
      :id => id, :status => status, :percent => percent,
      :total => total_compounds, :processed => processed_compounds, :failed => failed_compounds,
      :current_cid => current_cid, :message => message,
      :started_at => started_at, :finished_at => finished_at,
      :logs => logs.map { |l| { :id => l.id, :cid => l.cid, :num_modes => l.num_modes, :success => l.success, :message => l.message } }
    }
  end
end
