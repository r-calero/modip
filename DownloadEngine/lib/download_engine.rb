require 'pubchem/service_rest'
require 'pubchem/Assay/table_info'
require 'pubchem/Compound/sdf_compound'
require 'pubchem/Substance/sdf_substance'
require 'notification/notification_class'
require 'notification/assay_notification_class'
require 'notification/compound_notification_class'
require 'notification/count_notification_class'
require 'notification/finished_notification_class'
require 'notification/pipe_communication'
require 'extensor/array'
require 'Utilities'
require 'tmpdir'
require 'date'
require 'logger'
require 'thread'
require 'set'

# Downloads the PubChem assays found by a query, their compounds (3D, or 2D
# converted to 3D with Open Babel) and the data table of each assay, and
# stores them through the DataBaseServer (DRb).
#
# Speed:
#   - assays are processed in parallel by a pool of threads (MODIP_DOWNLOAD_THREADS,
#     default 2); every thread shares the PUG REST client, so the PubChem rate
#     limit (5 requests/s) still holds for the whole process;
#   - compounds are requested in batches of COMPOUND_BATCH CIDs (one request
#     for the 3D records and one for the 2D records of the whole batch);
#   - assay rows are sent to the database in batches of ROW_BATCH.
#
# Converting a 2D compound to 3D (Open Babel 2.3 --gen3D) is the slowest step:
# tens of seconds per molecule, and some molecules never finish. Open Babel
# already uses several cores, so conversions run one at a time by default
# (MODIP_BABEL_PROCESSES) and each one is stopped after MODIP_BABEL_TIMEOUT
# seconds (default 300); the compound is then stored in 2D.
#
# Progress notifications carry the assay id (aid), so the download server can
# compute the progress of assays running at the same time.
class DownloadEngine
  include WebUtilities
  @@coordinate3D = 2
  @@modipCoordinateUnitId = 10
  @@modipCoordinateSourceId = 7
  @@pubChemDataBase = 'pcassay'
  @@sid = "SID"
  @@cid = "CID"
  @@comment = "Comment"
  @@bio_assay_source = "BioAssay_Source"

  COMPOUND_BATCH = 100
  ROW_BATCH = 200

  def initialize(database_server, notify_server, assays_root, download_2d, download_3d, proxy = "", threads = nil)
    @babel_command = "babel"
    @sdf_extension = "sdf"
    @database_server = database_server
    @notify_server = notify_server
    @assays_root = assays_root
    @download_2d = download_2d
    @download_3d = download_3d
    @optional_search = {:webEnv => nil, :queryKey => nil, :useHistory => 'y', :tool => 'ruby', :email => 'modipserver@gmail.com', :field => nil, :reldate => nil, :datetype => 'edat',:retStart => 0, :retMax => 50, :rettype => 'uilist', :sort => nil}
    @assay_info = {:assayColumnType => AssayColumnsType::EAssayColumns_Concise, :listKeyTIDs =>'', :listKeySCIDs => '', :assayFormat => AssayFormatType::EAssayFormat_CSV, :compressType =>  CompressType::ECompress_None, :getVersion => true, :getCounts => true, :getFullDataBlog => false, :formatType => FormatType::EFormat_XML }
    @comp_info = {:format => FormatType::EFormat_SDF, :compress => CompressType::ECompress_None}
    @proxy = proxy
    @service = ServiceRest.new(@proxy)
    @threads = [(threads || setting('MODIP_DOWNLOAD_THREADS') || 2).to_i, 1].max
    @babel_processes = [(setting('MODIP_BABEL_PROCESSES') || 1).to_i, 1].max
    @babel_timeout = [(setting('MODIP_BABEL_TIMEOUT') || 300).to_i, 1].max
    @running = false
    @stopping = false
    @pids = []
    @workers = []
    @helpers = []
    @lock = Mutex.new        # active assays/compounds and child processes
    @notify_lock = Mutex.new # notifications are sent one at a time
    @active_aids = Set.new
    @active_cids = Set.new
  end

  def logger
    @@logger ||= Logger.new("./log/service.log",'daily')
  end

  def proxy
    @proxy
  end

  def proxy= (other)
    @proxy = other
    @service.proxy = @proxy
  end

  # Converts a 2D SDF to 3D. Waits for its own process only (other threads
  # may be running babel at the same time) and for @babel_timeout seconds at
  # most. Returns true when the conversion finished in time.
  def babel(input, output, input_extension, output_extension)
    logger.info("Converting compound: #{input} in 2D to: #{output} in 3D format")
    pid = fork do
      exec("#{@babel_command} -i #{input_extension} #{input} -o #{output_extension} #{output} --gen3D")
    end
    @lock.synchronize { @pids << pid }
    deadline = Time.now + @babel_timeout
    until Process.waitpid(pid, Process::WNOHANG)
      if Time.now > deadline
        kill_process(pid)
        File.delete(output) if File.exist?(output)
        logger.warn("Open Babel stopped after #{@babel_timeout}s converting #{input}")
        return false
      end
      sleep 0.5
    end
    true
  ensure
    @lock.synchronize { @pids.delete(pid) } if pid
  end

  def download(id, query, target, filter = AssayOutcomeFilterType::EAssayOutcome_All, min_date = nil, max_date = nil)
    @running = true
    @stopping = false
    @thread = Thread.new do
      begin
        aids = search_assays(query, min_date, max_date)
        notify(CountNotificationClass.new(id, aids.size, "AssayCount", "total assay #{aids.size}"))
        run_in_pool(aids) { |aid| process_assay(id, target, aid, filter) }
        notify(FinishedNotificationClass.new(id, Time.now, "download complete")) unless @stopping
      rescue Exception => e
        notify(FinishedNotificationClass.new(id, Time.now, "download error, details:\n#{e.message}", "Stop"))
      ensure
        @running = false
      end
    end
  end

  # Every assay id of the query (E-utilities returns them in pages of retMax).
  def search_assays(query, min_date, max_date)
    search = @optional_search.merge(:mindate => min_date, :maxdate => max_date, :retStart => 0, :webEnv => nil, :queryKey => nil)
    result = @service.eSearch(@@pubChemDataBase, query, search)
    total = result.Count.to_i
    aids = result.ids.map { |aid| aid.to_s }
    page = search[:retMax]
    if total > page
      search[:webEnv] = result.webEnv
      search[:queryKey] = result.queryKey
      (1..(total / page)).each do |i|
        search[:retStart] = i * page
        aids.concat(@service.eSearch(@@pubChemDataBase, query, search).ids.map { |aid| aid.to_s })
      end
    end
    aids.uniq
  end

  # Downloads one assay (description, columns and data table) and its compounds.
  def process_assay(id, target, aid, assay_filter)
    result, assay_path = @database_server.checkout_assay(aid)
    if result == 1 # being processed by another process
      notify(AssayNotificationClass.new(id, aid, "AssayProcessed", "the assay #{aid} is being processed by another process"))
      return assay_completed(id, aid, 0)
    end
    if result == 0 # the assay is not in the database yet
      track(@active_aids, aid)
      table_info = download_assay(id, target, aid, assay_filter)
      return assay_completed(id, aid, 0) unless table_info
    else # the assay is already in the database
      table_info = TableInfo.new(assay_path)
      notify(AssayNotificationClass.new(id, aid, "AssayProcessed", "assay #{aid} was processed"))
    end
    total = table_info.length
    notify(CountNotificationClass.new(id, total, "CompoundCount", "total compound #{total}", aid))
    assay_completed(id, aid, process_compounds(id, aid, table_info))
  rescue Exception => e
    release(:assay, aid) if @active_aids.include?(aid)
    notify(AssayNotificationClass.new(id, aid, "AssayFailed", "assay #{aid} unexpected error, details:\n#{e.message}"))
    assay_completed(id, aid, 0)
  end

  def download_assay(id, target, aid, assay_filter)
    step = "description"
    assay_description = @service.GetAssayDescription(aid, @assay_info[:getVersion], @assay_info[:getCounts], @assay_info[:getFullDataBlog], @assay_info[:formatType]).assayDescription
    step = "column description"
    column_description = @service.get_column_descriptions(aid)
    step = "compound information"
    table_info = get_table_info(aid, assay_filter)
    @database_server.insert_assay(aid, target, assay_description, column_description, table_info.path)
    release(:assay, aid)
    notify(AssayNotificationClass.new(id, aid, "AssayInserted", "assay #{aid} was inserted"))
    table_info
  rescue Exception => e
    release(:assay, aid)
    notify(AssayNotificationClass.new(id, aid, "AssayFailed", "assay #{aid} download #{step} error, details:\n#{e.message}"))
    nil
  end

  # Processes the rows of an assay in batches; returns the number of rows done.
  def process_compounds(id, aid, table_info)
    header = table_info.header
    done = 0
    table_info.each_batch(COMPOUND_BATCH) do |rows|
      break if @stopping
      by_cid = {}
      rows.each { |row| (by_cid[row[@@cid].to_s] ||= []) << row }
      ready = process_compound_batch(id, aid, by_cid.keys)
      lines = []
      by_cid.each do |cid, list|
        list.each { |row| lines << [cid, row.fields] } if ready.include?(cid)
      end
      lines.each_slice(ROW_BATCH) { |slice| @database_server.insert_assay_rows(aid, slice, header) }
      done += rows.size
      notify(CountNotificationClass.new(id, done, "CompoundProgress", "#{done} rows of assay #{aid} processed", aid))
    end
    done
  end

  # Makes sure every CID is in the database. Returns the CIDs that are.
  def process_compound_batch(id, aid, cids)
    ready = Set.new
    to_download = []
    cids.each do |cid|
      case @database_server.checkout_compound(cid)
      when 0 # the compound is not in the database yet
        track(@active_cids, cid)
        to_download << cid
      when 1 # being processed by another process
        notify(CompoundNotificationClass.new(id, cid, "CompoundProcessed", "the compound #{cid} is being processed by another process", aid))
      else
        ready << cid
        notify(CompoundNotificationClass.new(id, cid, "CompoundProcessed", "compound #{cid} was processed", aid))
      end
    end
    return ready if to_download.empty?

    records_3d = fetch_records(id, aid, to_download, true)
    records_2d = fetch_records(id, aid, to_download, false)
    in_parallel(to_download, @babel_processes) do |cid|
      begin
        stored = store_compound(id, aid, cid, records_3d[cid], records_2d[cid])
        @lock.synchronize { ready << cid } if stored
      rescue Exception => e
        notify(CompoundNotificationClass.new(id, cid, "CompoundFailed", "unexpected error processing the compound: #{cid}, details:\n#{e.message}", aid))
      ensure
        release(:compound, cid)
      end
    end
    ready
  end

  def fetch_records(id, aid, cids, use3D)
    @service.download_compound_records(cids, use3D)
  rescue Exception => e
    notify(CompoundNotificationClass.new(id, cids.first, "CompoundWarning",
           "error downloading #{cids.size} compounds in #{use3D ? '3d' : '2d'}, details:\n#{e.message}", aid))
    {}
  end

  # Stores one compound: 3D record (or the 2D one converted to 3D), with the
  # data missing in the 3D record taken from the 2D one. Returns true if stored.
  def store_compound(id, aid, cid, sdf_3d, sdf_2d)
    unless sdf_2d
      notify(CompoundNotificationClass.new(id, cid, "CompoundWarning", "error downloading compound: #{cid} in 2d", aid),
             CompoundNotificationClass.new(id, cid, "CompoundFailed", "error downloading compound: #{cid}", aid))
      return false
    end
    notify(CompoundNotificationClass.new(id, cid, "CompoundWarning", "compound #{cid} has no 3D conformer in PubChem", aid)) unless sdf_3d
    cmp_2d = parse_compound(cid, sdf_2d)
    cmp = sdf_3d ? parse_compound(cid, sdf_3d) : nil
    cmp ? cmp.copy_missing_data(cmp_2d) : (cmp = cmp_2d)

    if (reason = discard_reason(cmp))
      notify(CompoundNotificationClass.new(id, cid, "CompoundFailed", "compound: #{cid} discarded because #{reason}", aid))
      return false
    end

    directory = File.join(cmp.is_3d ? @download_3d : @download_2d, cmp.filename)
    File.open(directory, 'w') { |f| f.puts cmp.to_s }
    cmp.path = directory
    unless cmp.is_3d
      output = File.join(@download_3d, cmp.filename)
      unless babel(directory, output, @sdf_extension, @sdf_extension)
        notify(CompoundNotificationClass.new(id, cid, "CompoundWarning", "the 3D conversion of compound #{cid} took more than #{@babel_timeout}s; it is stored in 2D", aid))
      end
      if File.file?(output)
        cmp.set_3d_coordinate(@@coordinate3D)
        cmp.set_coordinate_source(@@modipCoordinateSourceId)
        cmp.set_coordinate_unit(@@modipCoordinateUnitId)
        cmp.path = output
      end
    end
    @database_server.insert_compound(cmp)
    notify(CompoundNotificationClass.new(id, cid, "CompoundInserted", "compound #{cid} was inserted in #{cmp.is_3d ? '3D' : '2D'}. Locate at: #{cmp.path}", aid))
    true
  end

  # Compounds MODIP does not dock: mixtures, and molecules with tellurium or boron.
  def discard_reason(cmp)
    return "it has more than one molecule" if cmp.name.to_s =~ /;/
    formula = cmp.molecular_formula.to_s
    return "it contains Tellanyl elements" if formula =~ /Te/
    boron = formula.upcase[/B\w/]
    return "it contains Boron elements" if boron && boron != 'BR'
    nil
  end

  def parse_compound(cid, text)
    file = File.join(Dir.tmpdir, "#{cid}-#{Thread.current.object_id}.#{@sdf_extension}")
    File.open(file, 'w') { |f| f.write(text) }
    SDFCompound.new(file, "#{cid}.#{@sdf_extension}")
  ensure
    File.delete(file) if file && File.exist?(file)
  end

  def notify(*arg)
    @notify_lock.synchronize do
      @notify_server.notify(*arg)
      arg.each do |obj|
        logger.info("[#{obj.query_id}: #{obj.event}] #{obj.message}")
      end
    end
  end

  def stop()
    @stopping = true
    (@lock.synchronize { @helpers.dup } + @workers + [@thread]).compact.each { |t| t.kill if t.alive? }
    @lock.synchronize { @pids.dup }.each do |pid|
      begin
        Process.kill("TERM", pid)
      rescue StandardError
      end
    end
    @active_aids.to_a.each do |aid|
      unless @database_server.assay_find_by_aid(aid)
        Dir[File.join(@assays_root, aid + ".*")].each { |entry| File.delete(entry) }
      end
      release(:assay, aid)
    end
    @active_cids.to_a.each do |cid|
      Dir[File.join(Dir.tmpdir, cid + "*.#{@sdf_extension}")].each { |entry| File.delete(entry) }
      unless @database_server.compound_find_by_cid(cid)
        Dir[File.join(@download_3d, cid + ".*")].each { |entry| File.delete(entry) }
        Dir[File.join(@download_2d, cid + ".*")].each { |entry| File.delete(entry) }
      end
      release(:compound, cid)
    end
    @running = false
  end

  # Downloads the assay data table as <assays_root>/<aid>.csv
  def get_table_info(aid, assay_filter = AssayOutcomeFilterType::EAssayOutcome_All)
    dir = File.join(@assays_root, "#{aid}.csv")
    @service.download_assay_table(aid, dir, assay_filter)
    TableInfo.new(dir)
  end

  def get_compound(url, filename)
    filename = "#{filename}.#{@sdf_extension}"
    dir = File.join(Dir.tmpdir, filename)
    logger.info("Downloading compound: #{filename} from: #{url}")

    @service.download(url, dir)
    compound = nil
    case(@comp_info[:format])
      when FormatType::EFormat_SDF
        compound = SDFCompound.new(dir, filename)
    end
    File.delete(dir)
    return compound
  end

  def get_download_url(cid,format,is_3d = true)
    record_type = is_3d ? '3d' : '2d'
    return "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{cid}/record/#{format}/?record_type=#{record_type}"
  end

  def is_running
    @running
  end

  private

  # Environment value, or nil when unset or empty (docker compose passes "").
  def setting(name)
    value = ENV[name].to_s.strip
    value.empty? ? nil : value
  end

  def run_in_pool(items, &block)
    @workers = start_threads(items, @threads, &block)
    @workers.each { |t| t.join }
  end

  # Runs the block for every item with up to `size` threads (killed by stop).
  def in_parallel(items, size, &block)
    return items.each(&block) if size <= 1 || items.size <= 1
    threads = start_threads(items, size, &block)
    @lock.synchronize { @helpers.concat(threads) }
    threads.each { |t| t.join }
  ensure
    @lock.synchronize { @helpers -= threads } if threads
  end

  def start_threads(items, size)
    queue = Queue.new
    items.each { |item| queue << item }
    Array.new([size, items.size].min) do
      Thread.new do
        loop do
          break if @stopping
          item = begin
            queue.pop(true)
          rescue ThreadError
            break
          end
          yield item
        end
      end
    end
  end

  def kill_process(pid)
    Process.kill("TERM", pid)
    sleep 1
    Process.kill("KILL", pid)
  rescue StandardError
  ensure
    begin
      Process.waitpid(pid)
    rescue StandardError
    end
  end

  def assay_completed(id, aid, rows)
    notify(CountNotificationClass.new(id, rows, "AssayCompleted", "assay #{aid} completed", aid))
  end

  def track(set, value)
    @lock.synchronize { set << value }
  end

  def release(kind, value)
    @database_server.leave_resource(kind, value)
    @lock.synchronize { (kind == :assay ? @active_aids : @active_cids).delete(value) }
  end

end
