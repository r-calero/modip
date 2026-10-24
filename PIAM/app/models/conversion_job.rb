# 2D -> 3D conversion of a compound, run by a conversion worker through the
# conversion broker (Server/conversion_broker.rb).
#   queued -> running -> done | failed | timeout
# Failed and timed-out jobs are only retried by an administrator (Admin page).
class ConversionJob < ActiveRecord::Base
  PENDING = %w(queued running)
  FINISHED = %w(done failed timeout)

  belongs_to :compound
  belongs_to :query

  attr_accessible # written by the broker and the admin page only

  scope :pending, where(:status => PENDING)
  scope :unsuccessful, where(:status => %w(failed timeout))

  # Conversions queued or running for the compounds with these CIDs.
  def self.pending_for_cids(cids)
    cids = Array(cids).map(&:to_s)
    return 0 if cids.empty?
    pending.joins(:compound).where(:compounds => { :cid => cids }).count
  end

  # 3D conversions of the last download of a query (the compounds it queued):
  # {'total', 'done', 'failed', 'pending'}, or nil if it queued none.
  def self.summary_for_query(query_id)
    cids = CompoundNotification.joins(:notification, :compound_notification_type).
      where(:notifications => { :query_id => query_id }, :compound_notification_types => { :name => 'CompoundQueued3D' }).
      pluck(:cid).uniq
    return nil if cids.empty?
    latest = joins(:compound).where(:compounds => { :cid => cids }).group(:compound_id).maximum(:id).values
    counts = where(:id => latest).group(:status).count
    pending = PENDING.inject(0) { |sum, s| sum + counts[s].to_i }
    { 'total' => cids.size, 'done' => counts['done'].to_i, 'pending' => pending,
      'failed' => cids.size - pending - counts['done'].to_i }
  end

  # Workers seen recently: [[name, seconds since its last heartbeat, running jobs], ...]
  # Times are compared in MySQL: the broker writes them with NOW().
  def self.workers(within = 10 * 60)
    where('worker IS NOT NULL AND heartbeat_at > NOW() - INTERVAL ? SECOND', within.to_i).group(:worker).
      select("worker, TIMESTAMPDIFF(SECOND, MAX(heartbeat_at), NOW()) AS idle, SUM(status = 'running') AS running").
      order('worker').map { |r| [r.worker, r.idle.to_i, r.running.to_i] }
  end

  # Queues the conversion of every 2D compound that never had one (compounds
  # downloaded before the conversion queue existed). Returns how many.
  def self.backfill(timeout)
    connection.update("INSERT INTO conversion_jobs (compound_id, status, priority, timeout_seconds, created_at, updated_at) " \
      "SELECT c.id, 'queued', 0, #{timeout.to_i}, NOW(), NOW() FROM compounds c " \
      "WHERE (c.coordinate IS NULL OR c.coordinate NOT LIKE '%3D%') AND c.path IS NOT NULL " \
      "AND NOT EXISTS (SELECT 1 FROM conversion_jobs j WHERE j.compound_id = c.id)")
  end

  # Manual retry of every failed or timed-out conversion. Returns how many.
  def self.retry_all!(timeout)
    unsuccessful.update_all(:status => 'queued', :worker => nil, :claim_token => nil, :error => nil,
                            :timeout_seconds => timeout.to_i, :finished_at => nil, :updated_at => Time.now)
  end

  # Seconds allowed when an administrator retries a conversion.
  def self.retry_timeout
    value = ENV['MODIP_BABEL_RETRY_TIMEOUT'].to_s.strip
    value.empty? ? 900 : [value.to_i, 1].max
  end

  def self.default_timeout
    value = ENV['MODIP_BABEL_TIMEOUT'].to_s.strip
    value.empty? ? 300 : [value.to_i, 1].max
  end

  # Queues the job again (manual retry) with the retry timeout.
  def retry!(timeout)
    self.class.where(:id => id, :status => %w(failed timeout)).
      update_all(:status => 'queued', :worker => nil, :claim_token => nil, :error => nil,
                 :timeout_seconds => timeout.to_i, :finished_at => nil, :updated_at => Time.now) == 1
  end
end
