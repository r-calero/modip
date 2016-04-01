class PrepareReceptor < ActiveRecord::Base
  belongs_to :target
  belongs_to :receptor_type
  has_many :receptor_compounds

  def uploaded_receptor=(receptor_field)
    @receptor_file = receptor_field
  end

  def uploaded_ligand=(ligand_field)
    @ligand_field = ligand_field
  end

  def prepare_receptor_save()
    self.receptor = PIAM::Application::DOCKING_MANAGER.upload_file(target.name, File.basename(@receptor_file.original_filename), @receptor_file.read)
    #self.ligand = PIAM::Application::QUERY_MANAGER.upload_file(target.name, File.basename(@ligand_field.original_filename), @ligand_field.read)
    save

  end

end