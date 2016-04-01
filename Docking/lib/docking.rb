
class DockingManager

  @@format_type = { :acr => :arc, :alc => :alc, :arc => :arc, :bgf => :bgf, :box => :box, :bs => :bs,
                    :c3d1 => :c3d1, :c3d2 => :c3d2, :caccrt => :caccrt, :cache => :cache, :cacint => :cacint,
                    :can => :can, :car => :car, :ccc => :ccc, :cdx => :cdx, :cdxml => :cdxml, :cht => :cht,
                    :cif => :cif, :cml => :cml, :cmlr => :cmlr, :com => :com, :copy => :copy, :crk2d => :crk2d,
                    :crk3d => :crk3d, :csr => :csr, :cssr => :cssr, :ct => :ct, :dmol => :dmol, :ent => :ent,
                    :fa => :fa, :fasta => :fasta, :fch => :fch, :fchk => :fchk, :fck => :fck, :feat => :feat,
                    :fh => :feat, :fix => :fix, :fpt => :fpt, :fract => :fract, :fs => :fs, :fsa => :fsa,
                    :g03 => :g03, :g98 => :g98, :gam => :gam, :gamin => :gamin, :gamout => :gamout, :gau => :gau,
                    :gjc => :gjc, :gjf => :gjf, :gpr => :gpr, :gr96 => :gr96, :hin => :hin, :inchi => :inchi,
                    :inp => :inp, :ins => :ins, :jin => :jin, :jout => :jout, :mdl => :mdl, :mmd => :mmd,
                    :mmod => :mmod, :mol => :mol, :mol2 => :mol2, :molreport => :molreport, :moo => :moo,
                    :mop => :mop, :mopcrt => :mopcrt, :mopin => :mopin, :mopout => :mopout, :mpc => :mpc, :mpd => :mpd,
                    :mpqc => :mpqc, :mpqcin => :mpqcin, :nw => :nw, :nwo => :nwo, :pc => :pc, :pcm => :pcm, :pdb => :pdb,
                    :pdbqt => :pdbqt, :pov => :pov, :pqs => :pqs, :prep => :prep, :qcin => :qcin, :qcout => :qcout,
                    :report => :report, :res => :res, :rxn => :rxn, :sd => :sd, :sdf => :sdf, :smi => :smi, :sy2 => :sy2,
                    :tdd => :tdd,:test => :test, :therm => :therm, :tmol => :tmol, :txyz => :txyz, :unixyz => :unixyz,
                    :vmol => :vmol, :xed => :xed, :xml => :xml, :xyz => :xyz, :yob => :yob, :zin => :zin }

  def DockingManager.format_type()
    @@format_type
  end

  def initialize()
    @babel_command = "babel"
    @autodock_vina_command = "vina"
    @pids = []
    $LOAD_PATH.each do |dir|
    	receptor_path = File.join(dir, "prepare_receptor4.py") 
      ligand_path = File.join(dir, "prepare_ligand4.py") 
      if File.exist?(receptor_path) or File.exist?(ligand_path)
      	@receptor_command = "python #{receptor_path}"
      	@ligand_command = "python #{ligand_path}"
      	break
      end
    end
    
  end

  def babel(input, output, input_extension, output_extension)
    pid = fork do 
			exec("#{@babel_command} -i#{input_extension} #{input} -o#{output_extension} #{output}")
		  end
	@pids << pid
	Process.wait
	@pids.delete(pid)
  end

  def prepare_receptor(input, output)
    `#@receptor_command -r #{input} -o #{output}`
  end

  def prepare_ligand(input, output)
    pid = fork do 
				exec("#{@ligand_command} -l #{input} -o #{output}")
			end
	@pids << pid
	Process.wait
	@pids.delete(pid)
  end

  def autodock_vina(params)
    args = ""
    params.each do |key, value|
      args += "--#{key} #{value} "
    end
    pid = fork do 
				exec("#{@autodock_vina_command} #{args}")
			end
	@pids << pid
	Process.wait
	@pids.delete(pid)
  end
  
  def wait_process_finish()
	@pids.each do |pid|
		begin
			Process.kill("TERM", pid)
		rescue
		end
	end
	
  end

end
