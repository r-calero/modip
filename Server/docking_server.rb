require_relative 'schema'
require 'rubygems'
require 'docking'
require 'drb'
require 'drb/observer'
require 'tmpdir'

class DockingServer
  include DRb::DRbObservable

  def initialize(target_root)
    @target_root = target_root
    @docking = DockingManager.new
    @running_docking = {}
  end

  def is_docking(key)
    @running_docking[key] ? true : false
  end
  
  def get_resource(resource)
	f = File.open(resource, 'r')
	result = f.readlines
	f.close()
	result
  end

  def start_docking(key, target, compounds, background = false)
  	@running_docking[key] = []
  	@running_docking[key][0] = []
  	code = Time.now.to_i.to_s
    t = Thread.new do
      notify_docking = NotifyDocking.new(key)
      compounds.each do |compound|
        begin
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
        message += receptor.receptor_type.name + "\n"
        params = {:center_x => receptor.center_x, :center_y => receptor.center_y, :center_z =>   	receptor.center_z, :size_x => receptor.size_x, :size_y => receptor.size_y, :size_z => receptor.size_z,
                  :out => "#{target.root}/output/#{get_file_name(code, target.name, receptor.receptor_type.name, compound.cid)}.#{DockingManager.format_type[:pdbqt]}"}
        params[:num_modes] = receptor.number_of_conformer if receptor.number_of_conformer
        params[:energy_range] = receptor.energy_range if receptor.energy_range
        params[:cpu] = receptor.cpu_number if receptor.cpu_number
        @running_docking[key][0] << params[:out]
        conformer_path, _ = auto_docking(key, receptor.receptor, sdf_dir, params, code)
        result = get_conformer_value(conformer_path)
        #File.delete(conformer_path)
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
    path = File.join(@target_root, underscore(target_folder), file)
    File.open(path, 'w') do |f|
      f.puts data
    end
    path

  end

  def create_target_dir(target_name)
    name_folder = File.join(@target_root, underscore(target_name))
    output = File.join(name_folder, 'output')
    log = File.join(name_folder, 'log')
    Dir.mkdir name_folder unless File.exist?(name_folder)
    Dir.mkdir output unless File.exist?(output)
    Dir.mkdir log unless File.exist?(log)
    name_folder
  end

  def delete_receptor(receptor_path)
	Dir.glob(File.join(receptor_path, "**")).each do | entry|
		delete_receptor(entry)
	end
    File.directory?(receptor_path) ? Dir.delete(receptor_path) : File.delete(receptor_path)
  end

  def auto_docking(key, receptor_pdbqt, sdf_3d_dir, params, code)
    name, _ = File.basename(sdf_3d_dir).split('.')
    name =  "#{code}_#{name}"
    mol2 = DockingManager.format_type[:mol2]
    pdbqt = DockingManager.format_type[:pdbqt]
    mol2_output = "#{name}.#{mol2}"
    @running_docking[key][0] << mol2_output
    @docking.babel(sdf_3d_dir, mol2_output, DockingManager.format_type[:sdf], mol2)
    ligand_pdbqt = "#{name}.#{pdbqt}"
    @running_docking[key][0] << ligand_pdbqt
    @docking.prepare_ligand(mol2_output, ligand_pdbqt)
    File.delete(mol2_output)
    @running_docking[key][0].delete(mol2_output)
    params = {:receptor => receptor_pdbqt, :ligand => ligand_pdbqt}.merge(params)
    @docking.autodock_vina(params)
    File.delete(ligand_pdbqt)
    @running_docking[key][0].delete(ligand_pdbqt)
    [params[:out] ? params[:out] : "#{name}_#{out}.#{pdbqt}", params[:log]]

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

docking_server = DockingServer.new(target)
Signal.trap("TERM") do
                 puts 'Stopping ...'
                 docking_server.stop()
                 puts "Exiting"
                end

DRb.start_service('druby://localhost:1992', docking_server)
puts DRb.uri
begin               
	DRb.thread.join
rescue Exception
	Process.kill("TERM", Process.pid)
end
