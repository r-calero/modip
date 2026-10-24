require_relative 'conversion_tls'
require 'socket'
require 'tmpdir'
require 'fileutils'

# Conversion worker: asks the conversion broker for queued 2D compounds,
# converts them to 3D with Open Babel (--gen3D) and sends the result back.
# It only needs Open Babel and its certificate; it never connects to MySQL
# and has no access to the MODIP data volume. One conversion at a time, with
# MODIP_BABEL_THREADS threads; run more workers to use more cores.
#
# Settings (environment):
#   MODIP_BROKER_URI      drbssl://host:7443 of the broker
#   MODIP_WORKER_CERT     certificate of this worker (CN = worker name)
#   MODIP_WORKER_KEY      its private key
#   MODIP_CA_CERT         CA of the installation
#   MODIP_WORKER_LABEL    shown in the Admin page next to the worker name
#   MODIP_BABEL_COMMAND   Open Babel executable (default: babel)
#   MODIP_BABEL_THREADS   OpenMP threads of Open Babel (default: 4). With one
#                         thread per core it slows down badly as soon as
#                         anything else uses the CPU (docking, for example).
class ConversionWorker
  POLL_IDLE = 5
  HEARTBEAT = 15

  def initialize(broker_uri, label, babel = 'babel', threads = 4)
    @broker = DRbObject.new_with_uri(broker_uri)
    @label = label
    @babel = babel
    @threads = [threads.to_i, 1].max
    @stopping = false
    @pid = nil
    @job = nil
  end

  # Called from the signal handler; run_babel stops Open Babel.
  def stop
    @stopping = true
  end

  def run
    log("waiting for conversions from #{@broker.__drburi}")
    until @stopping
      begin
        job = @broker.claim(@label)
        job ? convert(job) : pause(POLL_IDLE)
      rescue DRb::DRbConnError => e
        log("broker unreachable (#{e.message}); retrying")
        pause(POLL_IDLE * 2)
      rescue ConversionTLS::NotAllowed => e
        log("#{e.message}: add it to MODIP_CONVERSION_WORKERS on the MODIP server")
        pause(60)
      rescue Exception => e
        log("error: #{e.class}: #{e.message}")
        pause(POLL_IDLE)
      end
    end
    release
  end

  private

  def convert(job)
    @job = job
    started = Time.now
    log("job #{job['job_id']}: converting CID #{job['cid']}")
    Dir.mktmpdir('modip-conversion') do |dir|
      input = File.join(dir, 'input.sdf')
      output = File.join(dir, 'output.sdf')
      File.open(input, 'w') { |f| f.write(job['sdf']) }
      outcome = run_babel(input, output, job['timeout'].to_i, job)
      return if outcome == :released
      if outcome == :lost
        log("job #{job['job_id']}: the broker took the job back; discarded")
      elsif outcome == :timeout
        @broker.fail(job['job_id'], job['token'], 'timeout', "Open Babel took more than #{job['timeout']}s")
        log("job #{job['job_id']}: timeout")
      elsif !File.size?(output)
        @broker.fail(job['job_id'], job['token'], 'failed', "Open Babel produced no 3D structure (exit #{outcome})")
        log("job #{job['job_id']}: failed (exit #{outcome})")
      else
        begin
          @broker.complete(job['job_id'], job['token'], File.read(output))
          log("job #{job['job_id']}: done in #{(Time.now - started).round}s")
        rescue ArgumentError => e
          log("job #{job['job_id']}: #{e.message}")
        end
      end
    end
  ensure
    @job = nil unless @stopping
  end

  # Exit status of Open Babel, or :timeout, :lost (the broker no longer
  # leases the job to us) or :released (the worker is stopping).
  def run_babel(input, output, timeout, job)
    @pid = Process.spawn({ 'OMP_NUM_THREADS' => @threads.to_s }, @babel, '-i', 'sdf', input, '-o', 'sdf', output, '--gen3D',
                         :in => :close, [:out, :err] => File::NULL, :pgroup => true)
    deadline = Time.now + [timeout, 1].max
    next_beat = Time.now + HEARTBEAT
    loop do
      if @stopping
        kill_babel
        return :released
      end
      _, status = Process.waitpid2(@pid, Process::WNOHANG)
      return status.exitstatus if status
      if Time.now > deadline
        kill_babel
        return :timeout
      end
      if Time.now > next_beat
        next_beat = Time.now + HEARTBEAT
        begin
          if @broker.heartbeat(job['job_id'], job['token']) == 'lost'
            kill_babel
            return :lost
          end
        rescue DRb::DRbConnError => e
          log("heartbeat failed (#{e.message})")
        end
      end
      sleep 0.5
    end
  ensure
    @pid = nil
  end

  def kill_babel
    pid = @pid
    return unless pid
    begin
      Process.kill('TERM', -pid)
      20.times { return if Process.waitpid(pid, Process::WNOHANG); sleep 0.1 }
      Process.kill('KILL', -pid)
      Process.waitpid(pid)
    rescue Errno::ESRCH, Errno::ECHILD
    end
  end

  # Gives the current job back to the queue when the worker stops.
  def release
    job = @job
    return unless job
    @broker.release(job['job_id'], job['token'])
    log("job #{job['job_id']}: released")
  rescue Exception => e
    log("could not release job #{job['job_id']}: #{e.message}")
  end

  def pause(seconds)
    (seconds * 2).times { break if @stopping; sleep 0.5 }
  end

  def log(message)
    puts "#{Time.now.strftime('%F %T')} [worker #{@label}] #{message}"
  end
end

def setting(name, default)
  value = ENV[name].to_s.strip
  value.empty? ? default : value
end

$stdout.sync = true
config = ConversionTLS.config(setting('MODIP_WORKER_CERT', '/certs/worker.crt'),
                              setting('MODIP_WORKER_KEY', '/certs/worker.key'),
                              setting('MODIP_CA_CERT', '/certs/ca.crt'), ConversionTLS::BROKER_NAME)
# Outgoing drbssl calls use the TLS settings of the local DRb service, which
# only listens on the loopback interface.
DRb.start_service('drbssl://127.0.0.1:0', nil, config)
worker = ConversionWorker.new(setting('MODIP_BROKER_URI', 'drbssl://conversion-broker:7443'),
                              setting('MODIP_WORKER_LABEL', Socket.gethostname),
                              setting('MODIP_BABEL_COMMAND', 'babel'),
                              setting('MODIP_BABEL_THREADS', '4'))
%w(TERM INT).each { |signal| Signal.trap(signal) { worker.stop } }
worker.run
