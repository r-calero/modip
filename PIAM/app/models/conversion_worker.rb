# Conversion worker as seen by the broker (Server/conversion_broker.rb).
# name is "<certificate CN>@<label>"; label is usually the container hostname.
class ConversionWorker < ActiveRecord::Base
  DISCONNECTED_AFTER = 120 # seconds without contact

  attr_accessible # written by the broker only

  # Workers seen in the last day, with the seconds since their last contact
  # (computed by MySQL, whose clock the broker uses).
  def self.recent
    select("conversion_workers.*, TIMESTAMPDIFF(SECOND, last_seen_at, NOW()) AS idle_seconds").
      where('last_seen_at > NOW() - INTERVAL 1 DAY').order('cn, label')
  end

  # Conversions finished in the last day: { [worker name, status] => count }
  def self.finished_last_day
    rows = connection.select_rows("SELECT worker, status, COUNT(*) FROM conversion_jobs " \
                                  "WHERE finished_at > NOW() - INTERVAL 1 DAY AND worker IS NOT NULL GROUP BY worker, status")
    Hash[rows.map { |worker, status, count| [[worker, status], count.to_i] }]
  end

  def idle_seconds
    read_attribute(:idle_seconds).to_i
  end

  # converting | idle | disconnected
  def state
    return 'disconnected' if idle_seconds > DISCONNECTED_AFTER
    current_job_id ? 'converting' : 'idle'
  end
end
