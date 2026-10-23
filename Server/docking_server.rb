require_relative 'schema'
require_relative 'drb_acl'
require_relative 'docking_queue'
require 'zlib'
require 'fileutils'
require 'stringio'
require 'rubygems/package'
require 'docking'
require 'drb'
require 'drb/observer'
require 'tmpdir'

class DockingServer
  include DRb::DRbObservable

  attr_accessor :queue

  def initialize(target_root)
    @target_root = target_root
    @docking = DockingManager.new
    @running_docking = {}
  end

  # ---- docking jobs (see docking_queue.rb) ----

  # Asks the queue to stop the compound being docked for a cancelled job.
  def cancel_job(job_id)
    @queue.cancel(job_id) if @queue
    true
  end

  # Bookkeeping of temporary/output files of a running docking (used by make_docking).
  def prepare_key(key)
    @cancel_requested = false
    @running_docking[key] ||= [[], nil]
  end

  def forget_files(key)
    @running_docking.delete(key)
  end

  # Stops the Open Babel / AutoDockTools / Vina processes in progress.
  def kill_running_processes
    @cancel_requested = true
    @docking.wait_process_finish
  end

  # ---- receptors and results ----

  # Converts an uploaded receptor PDB (inside data/Targets) to PDBQT with
  # AutoDockTools and returns the PDBQT path.
  def prepare_receptor_file(pdb_path)
    input = inside_target_root!(pdb_path)
    output = input.sub(/\.pdb\z/i, '') + '.pdbqt'
    inside_target_root!(output)
    # Adds polar hydrogens when the PDB has none (needed by Vina).
    @docking.prepare_receptor(input, output, "-A checkhydrogens")
    raise "AutoDockTools could not prepare the receptor #{File.basename(input)}" unless File.size?(output)
    pdb_path.sub(/\.pdb\z/i, '') + '.pdbqt'
  end

  # .tar.gz (as a String) with the given docking result files (inside data/Targets).
  def archive_files(paths, folder_name = 'poses')
    io = StringIO.new
    gzip = Zlib::GzipWriter.new(io)
    Gem::Package::TarWriter.new(gzip) do |tar|
      paths.uniq.each do |path|
        full = inside_target_root!(path)
        next unless File.file?(full)
        data = File.open(full, 'rb') { |f| f.read }
        tar.add_file_simple("#{safe_name(folder_name)}/#{File.basename(full)}", 0644, data.bytesize) { |f| f.write(data) }
      end
    end
    gzip.close
    io.string
  end

  def is_docking(key)
    @running_docking[key] ? true : false
  end

  def get_resource(resource)
    path = inside_target_root!(resource)
    File.open(path, 'r') { |f| f.readlines }
  end

  def start_docking(key, tid, compounds, background = false)
    puts "starting docking ..."
    target = Target.find(tid)
    @running_docking[key] = []
    @running_docking[key][0] = []
    code = Time.now.to_i.to_s
    t = Thread.new do
      notify_docking = NotifyDocking.new(key)
      compounds.each do |cid|
        begin
          compound = Compound.find_by_cid(cid)
          message, notify_docking.num_modes = make_docking(key, target, compound, code)
          notify_docking.message = message + "\n"
        rescue Exception => e
          notify_docking.message = e.backtrace.join("\n")

        end
        notify(notify_docking)
      end
      notify_docking.event = "Finished"
      notify_docking.message = "finished docking"
      notify(notify_docking)
      @running_docking.delete(key)
    end
    @running_docking[key][1] = t
    t.join() if background
  end

  def stop()
  @running_docking.keys.each do |key|
    stop_docking(key)
  end
  end

  def stop_docking(key)
    files, thread = @running_docking[key]
  if thread
    thread.kill
    @docking.wait_process_finish()
    files.each do |file|
      if File.exist?(file)
        File.delete(file)
        puts "file #{file} delete"
      end
    end
    puts "stop docking"
    files
  else
    puts "not docking running for key: #{key}"
    []
    end

  end

  def make_docking(key, target, compound, code)
    message = "Processed Compound cid = #{compound.cid}\n"
    num_modes = 0
    if compound.coordinate =~ /3D/i
      sdf_dir = compound.path
      target.prepare_receptors.each do |receptor|
        raise "Docking cancelled" if @cancel_requested
        message += receptor.receptor_type.name + "\n"
        params = {:center_x => receptor.center_x, :center_y => receptor.center_y, :center_z =>    receptor.center_z, :size_x => receptor.size_x, :size_y => receptor.size_y, :size_z => receptor.size_z,
                  :out => "#{target.root}/output/#{get_file_name(code, target.name, receptor.receptor_type.name, compound.cid)}.#{DockingManager.format_type[:pdbqt]}"}
        params[:num_modes] = receptor.number_of_conformer if receptor.number_of_conformer
        params[:energy_range] = receptor.energy_range if receptor.energy_range
        params[:cpu] = receptor.cpu_number if receptor.cpu_number
        @running_docking[key][0] << params[:out]
        conformer_path, _ = auto_docking(key, receptor.receptor, sdf_dir, params, code)
        result = get_conformer_value(conformer_path)
        result.each_with_index do |value, index|
          compound.receptor_compound.create(:prepare_receptor => receptor, :value => value, :path => conformer_path)
          message += "Model #{index} result:  #{value}\n"
          num_modes += 1
        end
      end
    else
      message += "can't process 2D compound\n"
    end
    [message, num_modes]
  end

  def upload_file(target_folder, file, data)
    path = File.join(@target_root, safe_name(target_folder), safe_name(File.basename(file.to_s)))
    inside_target_root!(path)
    File.open(path, 'w') do |f|
      f.puts data
    end
    path

  end

  def create_target_dir(target_name)
    name_folder = File.join(@target_root, safe_name(target_name))
    inside_target_root!(name_folder)
    output = File.join(name_folder, 'output')
    log = File.join(name_folder, 'log')
    Dir.mkdir name_folder unless File.exist?(name_folder)
    Dir.mkdir output unless File.exist?(output)
    Dir.mkdir log unless File.exist?(log)
    name_folder
  end

  # Deletes a receptor file or a whole target folder (recursively), never
  # anything outside data/Targets nor the Targets folder itself.
  def delete_receptor(receptor_path)
    path = inside_target_root!(receptor_path)
    raise ArgumentError, "refusing to delete the targets root" if path == File.expand_path(@target_root)
    return unless File.exist?(path)
    Dir.glob(File.join(path, "**")).each do |entry|
      delete_receptor(entry)
    end
    File.directory?(path) ? Dir.delete(path) : File.delete(path)
  end

  def auto_docking(key, receptor_pdbqt, sdf_3d_dir, params, code)
    ligand_pdbqt = cached_ligand(key, sdf_3d_dir, code)
    params = {:receptor => receptor_pdbqt, :ligand => ligand_pdbqt}.merge(params)
    @docking.autodock_vina(params)
    [params[:out], params[:log]]
  end

  # Ligand PDBQT of a compound, prepared once (Open Babel + prepare_ligand4)
  # and reused for every receptor and docking job: data/Ligands/<cid>.pdbqt.
  def cached_ligand(key, sdf_3d_dir, code)
    folder = File.join(File.dirname(@target_root), "Ligands")
    FileUtils.mkdir_p(folder)
    name = File.basename(sdf_3d_dir).split('.').first
    ligand = File.join(folder, "#{name}.pdbqt")
    return ligand if File.size?(ligand) && File.mtime(ligand) >= File.mtime(sdf_3d_dir)

    # Temporary files next to the cache, so the final rename stays on the same
    # file system (data/ is a separate Docker volume).
    work = File.join(folder, ".#{code}_#{name}_#{Thread.current.object_id}")
    mol2 = "#{work}.#{DockingManager.format_type[:mol2]}"
    pdbqt = "#{work}.#{DockingManager.format_type[:pdbqt]}"
    @running_docking[key][0] << mol2 << pdbqt
    begin
      @docking.babel(sdf_3d_dir, mol2, DockingManager.format_type[:sdf], DockingManager.format_type[:mol2])
      @docking.prepare_ligand(mol2, pdbqt)
      raise "the ligand of #{name} could not be prepared" unless File.size?(pdbqt)
      File.rename(pdbqt, ligand)
    ensure
      [mol2, pdbqt].each { |f| File.delete(f) if File.exist?(f) }
      @running_docking[key][0].delete(mol2)
      @running_docking[key][0].delete(pdbqt)
    end
    ligand
  end

  def babel(input, output)
    @docking.babel(input, output, 'sdf', 'mol2')
  end

  def prepare_ligand(input, output)
    @docking.prepare_ligand(input, output)
  end

  def notify(*args)
    args.each do |arg|
      puts arg.message
    end
    changed
    notify_observers(*args)
  end

  class NotifyDocking
    include DRb::DRbUndumped

    attr_reader :key
    attr_accessor :message, :event, :num_modes

    def initialize(id, num_modes = 0, event = "CompoundProcessed", message = "")
      @key = id
      @num_modes = num_modes
      @event = event
      @message = message
    end
  end

  private

  # Absolute path of `path` if it is inside the targets folder; raises otherwise.
  def inside_target_root!(path)
    root = File.expand_path(@target_root)
    full = File.expand_path(path.to_s)
    unless full == root || full.start_with?(root + File::SEPARATOR)
      raise ArgumentError, "path outside the targets folder: #{path}"
    end
    full
  end

  # Folder/file name without path separators or "..".
  def safe_name(name)
    cleaned = underscore(name.to_s).gsub(/[^A-Za-z0-9_.\-]/, '_').gsub(/\.{2,}/, '_')
    raise ArgumentError, "invalid name: #{name}" if cleaned.empty? || cleaned == '.'
    cleaned
  end

  def get_conformer_value(conformer_path)
   result = []
    File.open(conformer_path, 'r').each do |line|
      if line =~ /REMARK VINA RESULT:/
        result << line.scan(/-?\d+\.?\d+/)[0].to_f
      end
    end
   result
  end

  def underscore(name)
    name.gsub(/\s+/, '_')
  end

  def get_file_name(code, *args)
    result = ""
    args << code
    result = underscore(args.join(" "))
    result
  end

end

data = "data"
target = File.join(data, "Targets")
Dir.mkdir(data) unless File.exist?(data)
Dir.mkdir(target) unless File.exist?(target)

ModipDrbAcl.install
docking_server = DockingServer.new(target)
docking_server.queue = DockingQueue.new(docking_server).start
Signal.trap("TERM") do
                 puts 'Stopping ...'
                 docking_server.stop()
                 puts "Exiting"
                end

DRb.start_service(ENV['MODIP_DOCKING_DRB_URI'] || 'druby://localhost:1997', docking_server)
puts DRb.uri
begin
  DRb.thread.join
rescue Exception
  Process.kill("TERM", Process.pid)
end
