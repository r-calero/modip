require_relative 'schema'
require_relative 'drb_acl'
require_relative 'conversion_tls'
require 'securerandom'
require 'fileutils'
require 'logger'

# Conversion broker: hands the queued 2D -> 3D conversions (conversion_jobs)
# to the conversion workers (conversion_worker.rb) and stores their results.
#
# Workers may run on other machines. They only talk to this broker, over
# mutual TLS (drbssl://): the CN of their certificate is their identity and
# must be listed in MODIP_CONVERSION_WORKERS. Workers never touch MySQL or the
# data volume; the broker sends them the 2D SDF and validates the 3D SDF they
# return before storing it.
#
# A job whose worker stops sending heartbeats for MODIP_CONVERSION_LEASE
# seconds is queued again; after two lost attempts it fails. Failed and
# timed-out jobs are only retried by an administrator (Admin page).
class ConversionBroker
  MAX_ATTEMPTS = 2
  MAX_SDF_BYTES = 5 * 1024 * 1024
  MODIP_COORDINATE_SOURCE = 7 # computed by MODIP (Open Babel)
  ANGSTROM_UNIT = 10

  def initialize(data_root, logger = Logger.new($stdout))
    @data_root = data_root
    @logger = logger
    @allowed = ENV['MODIP_CONVERSION_WORKERS'].to_s.split(',').map { |n| n.strip }.reject { |n| n.empty? } - [ConversionTLS::BROKER_NAME]
    @lease = [(ENV['MODIP_CONVERSION_LEASE'].to_s.strip.empty? ? 120 : ENV['MODIP_CONVERSION_LEASE'].to_i), 10].max
    @logger.info("[broker] allowed workers: #{@allowed.join(', ')}; lease #{@lease}s")
  end

  # Next queued job as a Hash (job_id, token, cid, sdf, timeout), or nil.
  def claim(label = nil)
    worker = authorize!
    name = [worker, label].compact.join('@')[0, 128]
    token = SecureRandom.hex(16)
    with_db do |db|
      claimed = db.update("UPDATE conversion_jobs SET status = 'running', worker = #{db.quote(name)}, claim_token = #{db.quote(token)}, " \
                          "claimed_at = NOW(), heartbeat_at = NOW(), attempts = attempts + 1, updated_at = NOW() " \
                          "WHERE status = 'queued' ORDER BY priority DESC, id LIMIT 1")
      return nil if claimed == 0
      job = ConversionJob.where(:claim_token => token).first
      compound = job.compound
      sdf = compound && compound.path && File.file?(full_path(compound.path)) ? File.read(full_path(compound.path)) : nil
      unless sdf
        finish(db, job.id, token, 'failed', 'The 2D file of the compound is missing')
        return nil
      end
      @logger.info("[broker] job #{job.id} (CID #{compound.cid}) -> #{name}")
      { 'job_id' => job.id, 'token' => token, 'cid' => compound.cid.to_s, 'sdf' => sdf, 'timeout' => job.timeout_seconds }
    end
  end

  # Keeps the job leased; returns 'running', or 'lost' when the worker no
  # longer owns it (lease expired or job cancelled).
  def heartbeat(job_id, token)
    authorize!
    with_db do |db|
      db.update("UPDATE conversion_jobs SET heartbeat_at = NOW() WHERE id = #{job_id.to_i} AND claim_token = #{db.quote(token)} AND status = 'running'") == 1 ? 'running' : 'lost'
    end
  end

  # Stores the 3D SDF of a job. Returns true, or raises with the reason the
  # result was rejected (the job is then marked as failed).
  def complete(job_id, token, sdf)
    authorize!
    with_db do |db|
      job = ConversionJob.where(:id => job_id.to_i, :claim_token => token, :status => 'running').first
      raise ArgumentError, "job #{job_id} is not leased to this worker" unless job
      compound = job.compound
      problem = invalid_result(compound, sdf.to_s)
      if problem
        finish(db, job.id, token, 'failed', "Rejected 3D result: #{problem}")
        raise ArgumentError, "rejected 3D result: #{problem}"
      end
      path = File.join('data', 'Compounds', '3D', File.basename(compound.path))
      tmp = full_path(path) + ".#{token}"
      File.open(tmp, 'w') { |f| f.write(sdf) }
      File.rename(tmp, full_path(path))
      ActiveRecord::Base.transaction do
        Compound.where(:id => compound.id).update_all(:path => path, :coordinate => '3D Coordinates',
          :coordinate_source_id => MODIP_COORDINATE_SOURCE, :coordinate_unit_id => ANGSTROM_UNIT)
        finish(db, job.id, token, 'done', nil)
      end
      @logger.info("[broker] job #{job.id} (CID #{compound.cid}) done")
      true
    end
  end

  # status: 'failed' or 'timeout'. The compound stays in 2D.
  def fail(job_id, token, status, message)
    authorize!
    status = status.to_s == 'timeout' ? 'timeout' : 'failed'
    with_db { |db| finish(db, job_id.to_i, token, status, message.to_s[0, 500]) }
  end

  # The worker is shutting down: the job goes back to the queue as it was.
  def release(job_id, token)
    authorize!
    with_db do |db|
      db.update("UPDATE conversion_jobs SET status = 'queued', worker = NULL, claim_token = NULL, attempts = GREATEST(attempts - 1, 0), " \
                "updated_at = NOW() WHERE id = #{job_id.to_i} AND claim_token = #{db.quote(token)} AND status = 'running'") == 1
    end
  end

  # Jobs whose worker went silent: queued again, or failed after MAX_ATTEMPTS.
  def expire_leases
    with_db do |db|
      stale = "status = 'running' AND heartbeat_at < NOW() - INTERVAL #{@lease} SECOND"
      failed = db.update("UPDATE conversion_jobs SET status = 'failed', claim_token = NULL, finished_at = NOW(), updated_at = NOW(), " \
                         "error = 'The worker stopped responding twice' WHERE #{stale} AND attempts >= #{MAX_ATTEMPTS}")
      requeued = db.update("UPDATE conversion_jobs SET status = 'queued', worker = NULL, claim_token = NULL, updated_at = NOW() WHERE #{stale}")
      @logger.warn("[broker] leases expired: #{requeued} queued again, #{failed} failed") if failed + requeued > 0
    end
  end

  private

  def authorize!
    name = ConversionTLS.peer_name
    unless name && @allowed.include?(name)
      @logger.warn("[broker] rejected worker #{name.inspect}")
      raise ConversionTLS::NotAllowed, "worker #{name.inspect} is not allowed"
    end
    name
  end

  def finish(db, job_id, token, status, message)
    db.update("UPDATE conversion_jobs SET status = #{db.quote(status)}, claim_token = NULL, error = #{db.quote(message)}, " \
              "finished_at = NOW(), updated_at = NOW() WHERE id = #{job_id.to_i} AND claim_token = #{db.quote(token)}") == 1
  end

  # Why a 3D SDF cannot be accepted for the compound, or nil if it is fine.
  def invalid_result(compound, sdf)
    return "empty result" if sdf.strip.empty?
    return "larger than #{MAX_SDF_BYTES} bytes" if sdf.bytesize > MAX_SDF_BYTES
    lines = sdf.lines.to_a
    return "not an SDF (no counts line)" if lines.size < 5
    atoms = lines[3][0, 3].to_i
    return "no atoms" if atoms <= 0 || lines.size < 4 + atoms
    coordinates = lines[4, atoms].map { |l| l.split[0, 3].map { |v| Float(v) rescue nil } }
    return "unreadable atom block" if coordinates.any? { |c| c.size < 3 || c.include?(nil) }
    return "coordinates are not 3D" if coordinates.all? { |c| c[2].abs < 0.001 }
    cid = sdf[/^> <PUBCHEM_COMPOUND_CID>\r?\n(\d+)/, 1]
    return "CID #{cid.inspect} instead of #{compound.cid}" if cid && cid != compound.cid.to_s
    original = File.file?(full_path(compound.path)) ? File.read(full_path(compound.path)) : nil
    heavy = lambda { |text| text.lines.to_a[4, text.lines.to_a[3][0, 3].to_i].count { |l| l.split[3] != 'H' } }
    return "different number of heavy atoms" if original && heavy.call(original) != heavy.call(sdf)
    nil
  end

  def full_path(path)
    File.expand_path(path.to_s, File.dirname(@data_root))
  end

  def with_db
    ActiveRecord::Base.connection_pool.with_connection { yield ActiveRecord::Base.connection }
  end
end

$stdout.sync = true
cert_dir = ENV['MODIP_CERT_DIR'].to_s.strip.empty? ? '/certs' : ENV['MODIP_CERT_DIR']
port = ENV['MODIP_CONVERSION_BROKER_PORT'].to_s.strip.empty? ? 7443 : ENV['MODIP_CONVERSION_BROKER_PORT'].to_i
broker = ConversionBroker.new(File.expand_path('data'))
ModipDrbAcl.install(ENV['MODIP_CONVERSION_ALLOW'])
config = ConversionTLS.config(File.join(cert_dir, 'broker.crt'), File.join(cert_dir, 'broker.key'), File.join(cert_dir, 'ca.crt'))
DRb.start_service("drbssl://0.0.0.0:#{port}", broker, config)
puts "conversion broker listening on #{DRb.uri}"

Thread.new do
  loop do
    begin
      broker.expire_leases
    rescue Exception => e
      puts "[broker] lease check failed: #{e.class}: #{e.message}"
    end
    sleep 30
  end
end

Signal.trap("TERM") { puts "Stopping ..."; exit }
DRb.thread.join
